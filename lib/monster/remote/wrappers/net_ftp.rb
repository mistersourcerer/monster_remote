require 'net/ftp'

module Monster
  module Remote
    module Wrappers

      class NetFTPPerf
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
            ftp.passive = true
            block.call(NetFTPHandler.new(ftp), ftp)
          end
          ftp.close
        end

      end# NetFTP

      class NetFTPHandler

        def initialize(ftp)
          @ftp = ftp
        end

        def create_dir(dir)
          pwd = @ftp.pwd

          dirs = dirs_in_path(dir)
          root_dir_name = dirs.shift

          create_and_chdir(root_dir_name)

          if dirs.size > 0
            dirs.each do |dir|
              create_and_chdir(dir)
            end
          end

          @ftp.chdir(pwd)
        end

        def remove_dir(dir)
          pwd = @ftp.pwd
          dirs = dirs_in_path(dir)
          final_dir = dirs.pop
          dirs.each { |dir| @ftp.chdir(dir) }
          empty_and_remove_dir(final_dir)
          while(final_dir = dirs.pop)
            @ftp.chdir("..")
            empty_and_remove_dir(final_dir)
          end
          @ftp.chdir(pwd)
        end

        def copy_file(from, to)
          if (dirs = dirs_in_path(to)).size > 1
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

        def entry_from_regex_on_path(regex, path)
          (matcher = regex.match(path)) && matcher[2].strip
        end

        def empty_dir(dir)
          pwd = @ftp.pwd
          @ftp.chdir(dir)
          res = @ftp.list;
          res.shift

          res.each do |item|
            if dir = entry_from_regex_on_path(/(^d.*)(\s.*)/i, item)
              remove_dir(dir)
            end

            if file = entry_from_regex_on_path(/(^-.*)(\s.*)/i, item)
              remove_file(file)
            end
          end

          @ftp.chdir(pwd)
        end

        def empty_and_remove_dir(dir)
          empty_dir(dir)
          if(@ftp.nlst.include?(dir))
            @ftp.rmdir(dir)
          end
        end

        def create_and_chdir(dir)
          create_dir_if_not_exists(dir)
          dir && @ftp.chdir(dir)
        end

        def dirs_in_path(dir)
          dirs_in_path = dir.gsub(/\.*\/$/, "").split("/")
        end

        def create_dir_if_not_exists(dir)
          begin
            dir && @ftp.mkdir(dir)
          rescue Net::FTPPermError => e
            is_unexpected_error = !e.message.include?("550")
            if is_unexpected_error
              raise(e, e.message, caller)
            end
          end
        end
      end# NetFTPHandler

    end# Wrappers
  end# Remote
end# Monster
