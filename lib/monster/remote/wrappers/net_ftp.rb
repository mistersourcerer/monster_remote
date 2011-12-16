require 'net/ftp'

module Monster
  module Remote
    module Wrappers

      class MonsterRemoteNetFTPWrapper < StandardError; end
      class NetFTPPermissionDenied < MonsterRemoteNetFTPWrapper; end

      class NetFTP
        def initialize(provider = Net::FTP)
          @provider = provider
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
        end

        def create_if_not_exists(dir)
          dir_info = @ftp.ls(dir)
          dir_exists = dir_info && dir_info.size > 0
          @ftp.mkdir(dir) unless dir_exists
        end

        def change_to(dir)
          @ftp.chdir(dir)
        end
      end

    end
  end
end
