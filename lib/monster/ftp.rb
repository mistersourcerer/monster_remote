require 'net/ftp'

module Monster
  class FTP

    def initialize(host, port = 21, user = nil, password = nil, abstraction = Net::FTP)
      @ftp = abstraction
      @host, @port, @user, @password = host, port, user, password
    end

    def send_directory(dir)
      @ftp.open(@host) do |ftp|
        ftp.connect(@host, @port)
      end
    end

  end
end
