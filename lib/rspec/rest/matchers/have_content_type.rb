require "rspec/rest/http/mime"

module RSpec
  module Rest
    module Matchers
      class HaveContentType < RSpec::Matchers::BuiltIn::BaseMatcher
        include RSpec::Rest::Http::Mime

        def initialize(expected_mime_type, expected_char_set = nil)
          @expected_mime_type = expected_mime_type
          @expected_char_set = expected_char_set
          @actual = nil
        end

        # @param [Object] response object providing an http code to match
        # @return [Boolean] `true` if the numeric code matched the `response` code
        def matches?(response)
          @actual = response.headers
          if @actual.key?("Content-Type")
            content_type = @actual.header["Content-Type"]
            if @expected_char_set
              [@expected_mime_type, @expected_char_set].zip(content_type.split(";").map(&:strip)).all? do |expected, actual|
                expected == actual
              end
            else
              @expected_char_set == content_type
            end
          else
            false
          end
        end
      end
    end
  end
end

