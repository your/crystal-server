require "../../src/crystal-server/store/file"
require "spec"
require "file_utils"

describe CrystalServer::Store::File do
  tmp_dir = "/tmp/crystal-server/test-run##{Time.now.epoch}"
  test_dir = "#{tmp_dir}/store/raw/bin"
  test_file = "#{test_dir}/test.png"
  test_content = "foobar"

  FileUtils.mkdir_p(test_dir)
  File.write(test_file, test_content)
  
  describe "#size" do
    it "returns the size of the file" do
      subject(test_file).size.should eq(test_content.size)
    end
  end

  describe "#type" do
    context "when extension is html" do
      it "returns html" do
        subject("/dev/null/test.html").type.should eq("html")
      end
    end

    context "when extension is js" do
      it "returns js" do
        subject("/dev/null/test.js").type.should eq("js")
      end
    end

    context "when extension is css" do
      it "returns css" do
        subject("/dev/null/test.css").type.should eq("css")
      end
    end

    context "when extension is something else" do
      it "returns bin" do
        subject("/dev/null/test.png").type.should eq("bin")
      end
    end
  end

  describe "#content" do
    context "where content is present" do
      it "returns the content as a UInt8 slice" do
        subject(test_file).content.should eq(test_content.to_slice)
      end
    end

    context "where content is not present" do
      it "returns an empty UInt8 slice" do
        subject("/dev/null/non-existent").content.should eq(Slice(UInt8).new(0))
      end
    end
  end

  FileUtils.rm_rf(tmp_dir)
end

private def subject(file_name)
  CrystalServer::Store::File.new(file_name)
end
