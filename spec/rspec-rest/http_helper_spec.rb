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
      response =  OpenStruct.new
      flexmock(response) do |res|
        res.should_receive(:code).and_return(201)
        res.should_receive(:body).and_return({:access => {:token => {:id => "token1", :expires => "2014-06-10T21:40:14Z", :tenant => {:id => "tenant1"}}}}.to_json)
        res.should_receive(:each_key).and_return({:dummy_header => "header1"})
      end
      flexmock(Net::HTTP).should_receive(:start).and_return(response)
    end
    with_authentication "user1"

    it "inejects token to request header" do
      get "/dummy"
    end
  end
end

