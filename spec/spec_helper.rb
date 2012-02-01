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

def local_dir
  File.join(spec_tmp, "_ftp_")
end

def remote_dir
  File.join("tmp", "_ftp_")
end

def dir_structure
  {
    "site" => ["xpto.txt"],
    "site/images" => ["img1", "img2", "img3"],
    "site/borba" => ["file1", "file2"],
    "site/borba/subdir" => ["entaro", "adum", "toredas"],
    "site/borba/subdir/test" => ["go1", "go2", "go3"]
  }
end

def create_dir_structure
  dir_structure.each do |dir, files|
    dir = File.join(local_dir, dir)
    FileUtils.mkdir_p(dir)
    files.each do |file|
      File.open(File.join(dir, file), "w") do |f|
        f.write(file)
      end
    end
  end
end
