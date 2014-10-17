require "simplecov"
SimpleCov.start

require "rspec/rest"

RSpec.configure do |c|
  c.config_path = "spec/target/config"
  c.template_path = "spec/target/template"
  c.mock_framework = :flexmock
  c.include RSpec::Rest::EnableSeparationLogger
end

