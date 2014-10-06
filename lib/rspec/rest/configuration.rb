require "rspec/core"

RSpec.configure do |c|
  c.add_setting :config_path, :default => "config/"
  c.add_setting :template_path, :default => "template/"
  c.add_setting :default_template_engine, :default => ".erb"
  c.add_setting :use_synonym, :default => true
end

