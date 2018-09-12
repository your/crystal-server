require "../../src/crystal-server/router"
require "spec"

describe CrystalServer::Router do
  describe "#translate_path" do
    context "when retrieving /filename" do
      it { router("/filename").translate_path.should eq("/raw/html/filename.html") }
    end

    context "when retrieving /filename.html" do
      it { router("/filename.html").translate_path.should eq("/raw/html/filename.html") }
    end

    context "when retrieving /filename.js" do
      it { router("/filename.js").translate_path.should eq("/raw/js/filename.js") }
    end

    context "when retrieving /filename.css" do
      it { router("/filename.css").translate_path.should eq("/raw/css/filename.css") }
    end

    context "when retrieving /filename.something-else" do
      it { router("/filename.something-else").translate_path.should eq("/raw/bin/filename.something-else") }
    end
  end
end

private def router(path)
  CrystalServer::Router.new(path)
end
