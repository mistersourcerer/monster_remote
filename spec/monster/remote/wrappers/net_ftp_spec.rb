module Monster
  module Remote
    module Wrappers

      describe NetFTP, "copy some local directory, to the remote host" do

        let(:dir_structure) do
          {
            "site" => ["xpto.txt"],
            "site/images" => ["img1", "img2", "img3"],
            "site/borba" => ["file1", "file2"],
            "site/borba/subdir" => ["entaro", "adum", "toredas"],
            "site/borba/subdir/test" => ["go1", "go2", "go3"]
          }
        end
        let(:local_dir) { File.join(spec_tmp, "_ftp_") }
        let(:wrapper) { NetFTP.new(local_dir) }

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

        before do
          FileUtils.mkdir_p(local_dir)
          create_dir_structure
        end

        context "#sync" do

          it "raise error if no local dir is configured" do
            #lambda { NetFTP.new.sync }.should raise_error(Monster::Remote::MissingLocalDirError)
          end

          it "calls provider #open" do
          end
        end# #sync

        context "syncing without configure the local dir" do

          it "#sync" do

          end
        end# empty local dir

        after do
          FileUtils.rm_rf(spec_tmp)
        end

      end# NetFTP
    end# Wrappers
  end# Remote
end# Monster
