require 'monster/remote/wrappers/net_ftp'
require 'monster/remote/filters/filter'
require 'monster/remote/filters/name_based_filter'
require 'monster/remote/configuration'
require 'monster/remote/sync'
require 'monster/remote/cli'

module Monster
  module Remote

    class MissingProtocolWrapperError < StandardError; end
    class MissingLocalDirError < StandardError; end
    class MissingRemoteDirError < StandardError; end
  end
end
