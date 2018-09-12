require "../../src/crystal-server/store/vault"
require "spec"
require "file_utils"

describe CrystalServer::Store::Vault do
  tmp_dir = "/tmp/crystal-server/test-run##{Time.now.epoch}"
  test_dir = "#{tmp_dir}/store/raw/bin"
  test_file = "#{test_dir}/test.png"
  test_content = "foobar"

  FileUtils.mkdir_p(test_dir)
  File.write(test_file, test_content)
  
  describe "#get" do
    it "returns the resource content" do
      subject = vault(tmp_dir).get("/store/raw/bin/test.png")
      content = subject.try &.content

      content.should eq(test_content.to_slice)
    end

    it "caches the resource" do
      vault = vault(tmp_dir)

      fetch1 = vault.get("/store/raw/bin/test.png")
      fetch2 = vault.get("/store/raw/bin/test.png")

      fetch1.object_id.should eq(fetch2.object_id)
    end
  end

  describe "#clear!" do
    it "clears the cache" do
      vault = vault(tmp_dir)
      
      vault.get("/store/raw/bin/test1.png")
      vault.get("/store/raw/bin/test2.png")

      vault.clear!.should eq(Hash(Nil, Nil).new)
    end
  end

  FileUtils.rm_rf(tmp_dir)
end

private def vault(base_dir)
  CrystalServer::Store::Vault.new(base_dir)
end
