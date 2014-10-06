require "spec_helper"
require "ostruct"

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
end
