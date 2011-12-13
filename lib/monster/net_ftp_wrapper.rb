require 'net/ftp'

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
            ftp.connect(host, port)
            ftp.login(user, pass)
            yield(self, ftp)
          end
        else
          ftp = @ftp_impl.new(host)
          ftp.connect(host, port)
          ftp.login(user, pass)
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

    end
  end
end
