require 'net/ftp'

module Monster
  module Remote
    module Wrappers

      class NetFTPWrapperPermissionDenied < Exception; end

      class NetFTPHandler

        def initialize(ftp)
          @ftp = ftp
        end

        def create_or_override_dir(dir)
          begin
            dir_exists = @ftp.nlst(dir)

            if dir_exists
              res = @ftp.list(dir)
              res.shift
              res.each do |item|
                dir = (matcher = /(^d.*)(\s.*)/i.match(item)) && matcher[2].strip
                file = (matcher = /(^d.*)(\s.*)/i.match(item)) && matcher[2].strip
                if dir
                  @ftp.rmdir(dir)
                end
                if file
                  @ftp.delete(file)
                end
              end
              @ftp.rmdir(dir)
            end
          rescue Net::FTPTempError => e
            msg = e.message
            is_empty_dir = msg.include?("450") && msg.include?("No files found")
            is_unexpected_error = !msg.include?("450")
            if is_empty_dir
              @ftp.rmdir(dir)
            end

            if is_unexpected_error
              raise(e, e.message, caller)
            end
          end

          @ftp.mkdir(dir)
        end

        def create_dir(dir, path = nil)
          is_root_dir = !path
          if is_root_dir
            dirs_in_path = dir.gsub(/\.*\/$/, "").split("/")

            create_or_override_dir(dirs_in_path[0])
            if dirs_in_path.size > 1
              path = dirs_in_path.shift
              dirs_in_path.each do |dir|
                create_dir(dir, path)
              end
            end
          end

          dir_path = path ? File.join(path, dir) : dir
          create_or_override_dir(dir_path)
        end

        def copy_file(from, to)
          @ftp.putbinaryfile(from, to)
        end

      end

      class NetFTP
        attr_writer :driver

        def initialize(driver=Net::FTP)
          @driver = driver
        end

        def open(host, user, password, port, &block)
          ftp = @driver.new
          ftp.connect(host, port)
          ftp.login(user, password)
          block.call(NetFTPHandler.new(ftp), ftp) if block
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
