
require "rspec/rest/matchers/have_http_status"
require "rspec/rest/matchers/have_http_header"
require "rspec/rest/matchers/include_json"
require "rspec/rest/matchers/have_uuid_format"
require "rspec/rest/matchers/contain"
require "rspec/rest/matchers/eql_json_value"

module RSpec
  module Rest
    module Matchers
      # from rspec-rails
      def have_http_status(code)
        RSpec::Rest::Matchers::HaveHttpStatus.new(code)
      end

      def have_json_path(json_path)
        RSpec::Rest::Matchers::JsonPath::InJsonPathMatcher.new(json_path)
      end

      def have_http_header(header)
        RSpec::Rest::Matchers::HaveHttpHeader.new(header)
      end

      def include_json(expected_json)
        RSpec::Rest::Matchers::IncludeJson.new(expected_json)
      end

      def have_uuid_format
        RSpec::Rest::Matchers::HaveUuidFormat.new
      end

      def have_guid_format
        RSpec::Rest::Matchers::HaveGuidFormat.new
      end

      def eql_json_value(actual)
        RSpec::Rest::Matchers::EqualJsonValue.new(actual)
      end

      def contain(target)
        RSpec::Rest::Matchers::Contain.new(target)
      end

      def contain_at_least(target)
        RSpec::Rest::Matchers::Contain.new(target, :at_least)
      end
      def contain_at_least(target)
        RSpec::Rest::Matchers::Contain.new(target, :at_most)
      end
    end
  end
end

