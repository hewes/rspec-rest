
module RSpec
  module Rest
    module Matchers
      class EqualJsonValue
        include RSpec::Rest::Matchers::JsonPath

        def initialize(expected)
          @expected = expected
        end

        def matches?(actual)
          @actual = actual
          @expected == actual
        end

        def failure_message
          "expect #{@actual} to be #{@expected} "
        end
      end
    end
  end
end
