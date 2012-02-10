require 'yaml'

module Monster
  module Remote

    class Configuration

      def initialize(configuration_file = "_config.yml")
        unless File.exists?(configuration_file)
          configuration_file = ".monster.yml"
        end

        @configs = {}

        begin
          file_info = YAML::load( File.open(configuration_file) )
          @configs = file_info && file_info["monster"] && file_info["monster"]["remote"]
        rescue Errno::ENOENT => e
        end
      end

      def password_required?
        read_config("pass")
      end

      def verbose?
        read_config("verbose")
      end

      private
      def expected
        [:host, :port, :user, :local_dir, :remote_dir, :verbose]
      end

      def respond_to?(method)
        expected.include? method || super
      end

      def method_missing(method, *args)
        if expected.include? method
          return read_config(method.to_s)
        end
        super
      end

      def read_config(name)
        @configs && @configs[name]
      end

    end# Configuration

  end# Remote
end# Monster
