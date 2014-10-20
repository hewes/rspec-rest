require "spec_helper"
require "ostruct"
require "json"
require "securerandom"

describe RSpec::Rest::Matchers::HaveHttpStatus do
  it "raises ArgumentError for invalid symbol" do
    expect{have_http_status(:dummy)}.to raise_error(ArgumentError, "invalid http status code: dummy")
  end

  it "raises  if actual value not respond to code" do
    expect{
      expect(100).to have_http_status(101)
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "100(Fixnum) does not respond to 'code'")
  end

  it "raises if not matched" do
    expect{
      expect(fake_response(100)).to have_http_status(101)
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "expect http status code 100 to be 101")
  end

  it "raises ArgumentError for other than symbol or int" do
    expect{have_http_status({:dummy => "value"})}.to raise_error(ArgumentError, "expected value must be Symbol or Fixnum")
  end

  it "matches with http status code specified as integer" do
    expect(fake_response(100)).to have_http_status(100)
  end

  it "matches with http status code specified as String" do
    expect(fake_response(100)).to have_http_status("100")
  end

  it "matches with http status code specified as symbol" do
    expect(fake_response(100)).to have_http_status(:continue)
    expect(fake_response(101)).to have_http_status(:switching_protocols)
    expect(fake_response(102)).to have_http_status(:processing)
    expect(fake_response(200)).to have_http_status(:ok)
    expect(fake_response(201)).to have_http_status(:created)
    expect(fake_response(202)).to have_http_status(:accepted)
    expect(fake_response(203)).to have_http_status(:non_authoritative_information)
    expect(fake_response(204)).to have_http_status(:no_content)
    expect(fake_response(205)).to have_http_status(:reset_content)
    expect(fake_response(206)).to have_http_status(:partial_content)
    expect(fake_response(207)).to have_http_status(:multi_status)
    expect(fake_response(226)).to have_http_status(:im_used)
    expect(fake_response(300)).to have_http_status(:multiple_choices)
    expect(fake_response(301)).to have_http_status(:moved_permanently)
    expect(fake_response(302)).to have_http_status(:found)
    expect(fake_response(303)).to have_http_status(:see_other)
    expect(fake_response(304)).to have_http_status(:not_modified)
    expect(fake_response(305)).to have_http_status(:use_proxy)
    expect(fake_response(307)).to have_http_status(:temporary_redirect)
    expect(fake_response(400)).to have_http_status(:bad_request)
    expect(fake_response(401)).to have_http_status(:unauthorized)
    expect(fake_response(402)).to have_http_status(:payment_required)
    expect(fake_response(403)).to have_http_status(:forbidden)
    expect(fake_response(404)).to have_http_status(:not_found)
  end

  def fake_response(code)
    OpenStruct.new(:code => code)
  end
end

describe RSpec::Rest::Matchers::IncludeJson do
  it "matches partial hash" do
    expect({"element1" => {"sub1" => "val1", "sub2" => "val2"}}.to_json).to include_json({"element1" => {"sub2" => "val2"}}.to_json)
  end

  it "matches nested partial hash" do
    expect({"element1" => {"sub1" => "val1", "sub2" => {"sub3" => "val2", "sub4" => "val3"}}}.to_json).to include_json({"element1" => {"sub2" => {"sub3" => "val2"}}}.to_json)
  end

  it "matches array" do
    expect(["element1"]).to include_json(["element1"])
  end

  it "matches partial array" do
    expect(["element1", "element2"]).to include_json(["element1"])
  end

  it "matches values in json path" do
    expect({"element1" => {"sub1" => "val1", "sub2" => {"sub3" => "val2"}}}.to_json).to include_json({"sub2" => {"sub3" => "val2"}}.to_json).in("element1")
  end

  it "raises if it does not have the json path" do
    expect{
      expect({"element1" => {"sub1" => "val1"}}.to_json).to include_json([:hoge].to_json).in("element1/sub2")
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, '{"element1":{"sub1":"val1"}} does not have json path "element1/sub2"')
  end
end

describe RSpec::Rest::Matchers::HaveUuidFormat do
  it "matches uuid format" do
    expect(SecureRandom.uuid).to have_uuid_format
    expect(SecureRandom.uuid.gsub("-", "")).to have_uuid_format
  end

  it "raises if not uuid format" do
    target = SecureRandom.uuid + "1"
    expect{
      expect(target).to have_uuid_format
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "#{target} is not UUID format")

    expect{
      expect(target[0...(-2)]).to have_uuid_format
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "#{target[0...(-2)]} is not UUID format")
  end

  it "matches uuid format in json path" do
    expect({:test => SecureRandom.uuid}.to_json).to have_uuid_format.in("test")
  end
end

describe RSpec::Rest::Matchers::HaveGuidFormat do
  it "matches uuid format" do
    expect(SecureRandom.uuid).to have_guid_format
  end

  it "matches uuid format in json path" do
    expect({:test => SecureRandom.uuid}.to_json).to have_guid_format.in("test")
  end

  it "raises if not guid format" do
    target = SecureRandom.uuid + "1"
    expect{
      expect(target).to have_guid_format
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "#{target} is not GUID format")

    expect{
      expect(target[0...(-2)]).to have_guid_format
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "#{target[0...(-2)]} is not GUID format")
  end
end

describe RSpec::Rest::Matchers::HaveJsonPath do
  it "matches json path" do
    expect({:test => :value}.to_json).to have_json_path("test")
    expect({:test => {:foo => :bar}}.to_json).to have_json_path("test/foo")
  end

  it "raises if not have json path" do
    expect{
      expect({:test => {:foo => :bar}} .to_json).to have_json_path("foo").and_item_size_is(2)
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, %Q({"test":{"foo":"bar"}} does not have json path "foo"))
  end

  it "matches json path and size" do
    expect({:test => {:foo => :bar}}.to_json).to have_json_path("test").and_item_size_is(1)
    expect({:test => {:foo => [1,2,3]}}.to_json).to have_json_path("test/foo").and_size(3)
  end

  it "raises if size not match" do
    expect{
      expect({:test => {:foo => :bar}} .to_json).to have_json_path("test").and_item_size_is(2)
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, %Q(expect 1 (size of {"foo"=>"bar"}) to equal 2 (test in {"test":{"foo":"bar"}})))
  end
end

