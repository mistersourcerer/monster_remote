require 'net/ftp'

module Monster
  module Remote
    module Wrappers

      class NetFTP

        def open(host, port, user, pass)
          
        end

        def copy_dir(local_dir, remote_dir)
          
        end
      end

    end
  end
end

module Monster
  module FTPWrapper
    class NetFTPWrapper

      def initialize(impl = Net::FTP)
        @ftp_impl = impl
      end

      def open(host, port = 21, user = nil, pass = nil)
        if block_given?
          @ftp_impl.open(host) do |ftp|
            @connection = ftp
            connection_login(host, port, user, pass)
            yield(self, ftp)
          end
        else
          @connection = @ftp_impl.new(host)
          connection_login(host, port, user, pass)
        end
        @connection
      end

      def remote_files
        
      end

      def copy_file(from, to)
        
      end

      def mkdir(remote_dir_name)
        
      end

      def close
        @connection.close
      end

      private
      def connection_login(host, port, user, pass)
        @connection.connect(host, port)
        @connection.login(user, pass)
      end

    end
  end
end
