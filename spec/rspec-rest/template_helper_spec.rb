require "spec_helper"

describe RSpec::Rest::Template::Helpers do
  it "loads template and returns it" do
    expect(template("template1.json.erb").with(:param => :hoge)).to eq("this is template for json with hoge")
  end

  it "loads nested template and returns it" do
    expect(template("nested/template1.erb").to_s).to eq("this is nested template")
  end
end

