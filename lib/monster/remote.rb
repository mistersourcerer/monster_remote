require 'monster/remote/sync'
require 'monster/remote/cli'
require 'monster/remote/wrappers/net_ftp'
require 'monster/remote/filters/filter'
require 'monster/remote/filters/name_based_filter'

module Monster
  module Remote

    class MissingProtocolWrapperError < StandardError; end
    class NoConnectionError < StandardError; end
    class MissingLocalDirError < StandardError; end
    class MissingRemoteDirError < StandardError; end
  end
end
