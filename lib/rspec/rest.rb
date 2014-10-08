require "rspec/rest/version"
require "rspec/rest/configuration"
require "rspec/rest/util"
require "rspec/rest/matchers"
require "rspec/rest/helpers"
require "rspec/rest/exceptions"

RSpec.configure do |c|
  c.include RSpec::Rest::Matchers
  c.include RSpec::Rest::Http::Helpers
  c.include RSpec::Rest::Template::Helpers
end

