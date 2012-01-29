#encoding: utf-8

$: << File.join(File.expand_path('../../', __FILE__), 'lib')
require 'monster_remote'
require 'fakefs/safe'

def spec_dir
  File.expand_path("../", __FILE__)
end

def spec_tmp
  File.join(spec_dir, "_tmp")
end
