module Monster
  module Remote

    class Sync

      attr_writer :verbose, :local_dir, :remote_dir

      def initialize(wrapper)
        @wrapper = wrapper
      end

      def start
        wrapper = @wrapper || raise(MissingProtocolWrapperError)
        local_dir || raise(MissingLocalDirError)
        remote_dir || raise(MissingRemoteDirError)

        out("syncing from: #{local_dir} to: #{remote_dir}")

        open(wrapper) do |wrapper|
          out("connection openned, using: #{wrapper}")
          copy_to_remote(wrapper, local_dir)
        end
      end

      private
      def create_dir(wrapper, local_dir_path, remote_dir_path, entry_path)
        out("creating dir #{remote_dir_path}")
        wrapper.create_dir(remote_dir_path)
        out("diggin into #{local_dir_path}")
        Dir.entries(local_dir_path).each do |dir|
          copy_to_remote(wrapper, dir, entry_path)
        end
      end

      def copy_file(wrapper, local_file, remote_file)
        out("coping file to #{remote_file}")
        wrapper.copy_file(local_file, remote_file)
      end

      def copy_to_remote(wrapper, entry, path=nil)
        is_dot_dir = entry =~ /^\.$|^\.\.$/
        return if is_dot_dir

        entry_path = path ? File.join(path, entry) : ""
        local_path = File.join(local_dir, entry_path).gsub(/\.*\/$/, "")
        remote_path = File.join(remote_dir, entry_path).gsub(/\.*\/$/, "")

        if File.directory?(local_path)
          create_dir(wrapper, local_path, remote_path, entry_path)
        else
          copy_file(wrapper, local_path, remote_path)
        end
      end

      def out(msg)
        @verbose && @verbose.puts(msg)
      end

      def local_dir
        @local_dir
      end

      def remote_dir
        @remote_dir
      end

      def open(wrapper, &block)
        begin
          wrapper.open &block
        rescue Exception => e
          raise NoConnectionError, e, caller
        end
      end

    end# Sync
  end
end
