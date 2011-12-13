require 'net/ftp'

module Monster
  module FTPWrapper
    class NetFTPWrapper

      def initialize(impl = Net::FTP)
        @ftp_impl = impl
      end

      def open(host, port = 21, user = nil, pass = nil)
        @ftp_impl.open(host) do |ftp|
          ftp.connect(host, port)
          ftp.login(user, pass)
          if block_given?
            yield(self, ftp)
          end
        end
      end

    end
  end
end
