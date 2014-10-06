require "json"

module RSpec
  module Rest
    module Matchers
      class IncludeJson < RSpec::Matchers::BuiltIn::Include
        def initialize(expected_json)
          super(arg2hash(expected_json))
        end

        def matches?(actual)
          super(arg2hash(actual))
        end

        private
        def arg2hash(arg)
          case arg
          when Hash,Array then arg
          when String then JSON.parse(arg)
          else raise ArgumentError.new("json must be Hash or String")
          end
        end
      end
    end
  end
end
