require 'monster/remote/net_ftp_wrapper'

module Monster
  module Remote

    class Sync

      def self.with
        Sync.new
      end

      def start
        
      end

      def local_dir(local_dir)
        @local_dir = local_dir
        self
      end

      def remote_dir(remote_dir)
        @local_dir = remote_dir
        self
      end

      def remote_connection_provider(provider)
        @provider = provider
        self
      end

      def host(host)
        @host = host
        self
      end

      def port(port)
        @port = port
        self
      end

      def user(user)
        @user = user
        self
      end

      def pass(pass)
        @pass = pass
        self
      end
    end

    class SyncOld

      def initialize(host, port = 21, user = nil, password = nil, abstraction = nil)
        @ftp = abstraction || FTPWrapper::NetFTPWrapper.new
        @host, @port, @user, @pass = host, port, user, password
      end

      def send_directory(dir, to = nil)
        @local_dir = dir
        @remote_dir = to || dir
        connect do |ftp|
          prepare_remote_dir(ftp)
          copy_directory(@local_dir, @remote_dir, ftp)
        end
      end

      private
      def connect
        @ftp.open(@host, @port, @user, @pass) do |ftp|
          yield(ftp)
        end
      end

      def prepare_remote_dir(ftp, remote_dir = nil)
        remote_dir ||= @remote_dir
        @remote_files ||= ftp.remote_files
        if !@remote_files.include?(remote_dir)
          ftp.mkdir(remote_dir)
          @remote_files << remote_dir
        end
      end

      def filter_content_of_directory(dir)
        Dir.entries(dir).reject do |name|
          name == "." || name == ".."
        end
      end

      def copy_file(file, remote_dir, ftp)
        to = remote_dir
        ftp.copy_file(file, to)
      end

      def copy_directory(from, to, ftp)
        filter_content_of_directory(from).each do |name|
          local_file = File.join(from, name)
          remote_file = File.join(to, name)
          copy(local_file, remote_file, ftp)
        end
      end

      def copy(from, to, ftp)
        if(File.directory?(from))
          prepare_remote_dir(ftp, to)
          copy_directory(from, to, ftp)
        else
          copy_file(from, to, ftp)
        end
      end

    end

  end
end
