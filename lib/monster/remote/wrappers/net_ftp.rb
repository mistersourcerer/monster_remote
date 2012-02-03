require 'net/ftp'

module Monster
  module Remote
    module Wrappers

      class NetFTPWrapperPermissionDenied < Exception; end

      class NetFTPHandler

        def initialize(ftp)
          @ftp = ftp
        end

        def create_dir(dir)
          pwd = @ftp.pwd

          dirs_in_path = dir.gsub(/\.*\/$/, "").split("/")
          root_dir_name = dirs_in_path.shift

          create_and_chdir(root_dir_name)

          if dirs_in_path.size > 0
            dirs_in_path.each do |dir|
              create_and_chdir(dir)
            end
          end

          @ftp.chdir(pwd)
        end

        def remove_dir(dir)
          pwd = @ftp.pwd
          @ftp.chdir(dir)
          res = @ftp.list; res.shift

          res.each do |item|
            dir = (matcher = /(^d.*)(\s.*)/i.match(item)) && matcher[2].strip
            if dir
              #@ftp.rmdir(dir)
              remove_dir(dir)
            end

            file = (matcher = /(^-.*)(\s.*)/i.match(item)) && matcher[2].strip
            if file
              remove_file(file)
            end
          end
          @ftp.chdir(pwd)
          @ftp.rmdir(dir)
        end

        def copy_file(from, to)
          file = to
          dirs = dirs_in_path(to)
          if dirs.size > 1
            file = dirs.pop
            create_dir(dirs.join("/"))
            pwd = @ftp.pwd
            dirs.each { |dir| @ftp.chdir(dir) }
            @ftp.putbinaryfile(from, file)
            @ftp.chdir(pwd)
          else
            @ftp.putbinaryfile(from, to)
          end
        end

        def remove_file(file)
          @ftp.delete(file)
        end

        private

        def create_and_chdir(dir)
          create_dir_if_not_exists(dir)
          @ftp.chdir(dir)
        end

        def dirs_in_path(dir)
          dirs_in_path = dir.gsub(/\.*\/$/, "").split("/")
        end

        def create_dir_if_not_exists(dir)
          is_new_dir = true
          begin
            is_new_dir = @ftp.nlst(dir)
          rescue Net::FTPTempError => e
            is_unexpected_error = !e.message.include?("450")
            if is_unexpected_error
              raise(e, e.message, caller)
            end

            is_new_dir = !e.message.include?("No files found")
          end

          if is_new_dir
            @ftp.mkdir(dir)
          end
        end

      end

      class NetFTP
        def initialize(driver=Net::FTP)
          @driver = driver
        end

        def open(host, user, password, port, &block)
          ftp = @driver.new
          ftp.connect(host, port)
          ftp.login(user, password)
          if block
            block.call(NetFTPHandler.new(ftp), ftp)
          end
          ftp.close
        end
      end# NetFTP

      class NetFTPOld

        def initialize(provider = Net::FTP)
          @provider = provider
          @filters = []
          @nslt = {}
        end

        def open(host, port, user, pass)
          @provider.open(host) do |ftp|
            @ftp = ftp
            @ftp.connect(host, port)
            @ftp.login(user, pass)
            yield(self, ftp)
          end
        end

        def copy_dir(local_dir, remote_dir)
          create_if_not_exists(remote_dir)
          local_structure = filter(Dir.entries(local_dir))
          local_structure.each do |entry|
            local_path = File.join(local_dir, entry)
            remote_path = File.join(remote_dir, entry)
            copy(local_path, remote_path)
          end
        end

        def add_filter(filter)
          @filters ||= []
          @filters << filter
        end

        private
        def copy(from, to)
          if(Dir.exists?(from))
            copy_dir(from, to)
          else
            copy_file(from, to)
          end
        end

        def copy_file(from, to)
          @ftp.putbinaryfile(from, to)
        end

        def filter(dir_structure)
          if(@filters.empty?)
            @filters << ContentNameBasedFilter.new.reject([".", ".."])
          end

          allowed = dir_structure
          @filters.each do |f|
            allowed = f.filter(allowed)
          end
          allowed
        end

        def create_remote_dir(dir)
          dirname = File.dirname(dir)
          dir_content = @nslt[dirname] || @ftp.nlst(dirname)
          dir_exists = dir_content.include? dir
          @ftp.mkdir(dir) unless dir_exists
        end

        def create_if_not_exists(dir)
          begin
            create_remote_dir(dir)
          rescue Net::FTPPermError => e
            denied = NetFTPPermissionDenied.new(e)
            raise denied, e.message
          end
        end

      end # NetFTP

    end
  end
end
