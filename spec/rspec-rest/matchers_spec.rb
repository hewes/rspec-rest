require "spec_helper"
require "ostruct"
require "json"

describe RSpec::Rest::Matchers::HaveHttpStatus do
  it "matches with http status code" do
    expect(fake_response(200)).to have_http_status(:ok)
    expect(fake_response(201)).to have_http_status(:created)
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
    expect({"element1" => {"sub1" => "val1", "sub2" => {"sub3" => "val2"}}}.to_json).to include_json({"element1" => {"sub2" => {"sub3" => "val2"}}}.to_json)
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
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, '{"element1"=>{"sub1"=>"val1"}} does not have json path "element1/sub2"')
  end
end

