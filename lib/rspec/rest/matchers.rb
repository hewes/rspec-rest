
require "rspec/rest/matchers/have_http_status"
require "rspec/rest/matchers/have_http_header"
require "rspec/rest/matchers/include_json"
require "rspec/rest/matchers/have_uuid_format"
require "rspec/rest/matchers/have_json_path"

module RSpec
  module Rest
    module Matchers
      # from rspec-rails
      def have_http_status(code)
        RSpec::Rest::Matchers::HaveHttpStatus.new(code)
      end

      def have_json_path(json_path)
        RSpec::Rest::Matchers::HaveJsonPath.new(json_path)
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
    end
  end
end

