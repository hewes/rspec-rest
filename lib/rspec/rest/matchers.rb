
require "rspec/rest/matchers/have_http_status"
require "rspec/rest/matchers/include_json"

module RSpec
  module Rest
    module Matchers
      # from rspec-rails
      def have_http_status(code)
        RSpec::Rest::Matchers::HaveHttpStatus.matcher_for(code)
      end

      def include_json(expected_json)
        RSpec::Rest::Matchers::IncludeJson.new(expected_json)
      end
    end
  end
end

