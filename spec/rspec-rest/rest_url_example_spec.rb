require "spec_helper"

describe "GET /dir1/file1.html", :type => :rest_url do
  describe "http_method" do
    it "returns GET as http_method" do
      expect(http_method).to be(:get)
    end
  end

  describe "request_path" do
    it "returns /dir1/file1.html as request_path" do
      expect(request_path).to eq("/dir1/file1.html")
    end
  end
end

describe "DELETE /dir1/:uuid", :type => :rest_url do
  describe "http_method" do
    it "returns DELETE as http_method" do
      expect(http_method).to be(:delete)
    end
  end

  describe "request_path" do
    it "returns /dir1/dummy_uuid as request_path" do
      @uuid = "dummy_uuid"
      expect(request_path).to eq("/dir1/dummy_uuid")
    end
  end
end
