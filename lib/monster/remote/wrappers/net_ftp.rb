require 'net/ftp'

module Monster
  module Remote
    module Wrappers

      class NetFTP
        def initialize(provider = Net::FTP)
          @provider = provider
        end

        def open(host, port, user, pass)
          @provider.open(host) do |connection|
            connection.connect(host, port)
            connection.login(user, pass)
            yield(self, connection)
          end
        end

        def copy_dir(local_dir, remote_dir)
        end

        def create_and_change_to(dir)
        end
      end

    end
  end
end
