require "net/http"

module RSpec
  module Rest
    module Matchers
      class HaveHttpHeader < RSpec::Matchers::BuiltIn::BaseMatcher
        def initialize(expected_header)
          @expected = expected_header
          @actual = nil
          @invalid_response = nil
        end

        # @param [Object] response object providing an http code to match
        # @return [Boolean] `true` if the numeric code matched the `response` code
        def matches?(response)
          @actual = response.headers
          @actual.key?(@expected)
        end
      end
    end
  end
end


