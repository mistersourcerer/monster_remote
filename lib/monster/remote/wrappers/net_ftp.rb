require 'net/ftp'

module Monster
  module Remote
    module Wrappers

      class NetFTPWrapperPermissionDenied < Exception; end

      class NetFTP
        attr_writer :driver

        def initialize(driver=Net::FTP)
          @driver = driver
        end

        def open(host, user, password, port)
          ftp = @driver.new
          ftp.connect(host, port)
          ftp.login(user, password)
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
