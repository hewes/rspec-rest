require "forwardable"
require "rspec/rest/matchers/in_json_path"

module RSpec
  module Rest
    module Matchers
      class HaveJsonPath
        extend Forwardable

        def initialize(json_path)
          @json_path = json_path
          @json_path_matcher = RSpec::Rest::Matchers::JsonPath::InJsonPathMatcher.new(@json_path)
        end
        def_delegators :@json_path_matcher, :matches?, :failure_message

        class SizeMatcher
          def initialize(expected)
            @expected = expected
          end

          def matches?(actual)
            if actual.respond_to?(:size)
              @message = "expect #{actual.size} (size of #{actual}) to equal #{@expected}"
              return actual.size == @expected
            else
              @message = "#{actual} does not respond to size"
              return false
            end
          end

          def failure_message
            @message
          end
        end

        def and_item_size_is(expected_size)
          RSpec::Rest::Matchers::JsonPath::InJsonPathMatcher.new(@json_path, SizeMatcher.new(expected_size))
        end
      end
    end
  end
end
