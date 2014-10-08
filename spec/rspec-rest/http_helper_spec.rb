require "spec_helper"
require "ostruct"
require "net/http"

describe RSpec::Rest::Http::Helpers do

  def mock_response(code, body, headers = {})
    flexmock(Net::HTTP).new_instances.should_receive(:request).and_return(:code => code, :body => body, :header => headers)
  end

  it "use default_request" do
    default_request do |req|
      req.content_mime_type = :json
    end
    get "/dummy"
  end

  describe "with_authentication" do
    before(:each) do
      response = OpenStruct.new(:code => 201, :body => {:access => {:token => {:id => "token1", :expires => "2014-06-10T21:40:14Z", :tenant => {:id => "tenant1"}}}}.to_json)

      obj = Object.new
      flexmock(obj).should_receive(:start).and_return(response)
      flexmock(Net::HTTP).should_receive(:new).and_return(obj)
    end
    with_authentication "user1"

    it "inejects token to request header" do
      get "dummy"
    end
  end
end

