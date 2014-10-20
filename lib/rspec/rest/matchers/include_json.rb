require "json"
require "rspec/rest/matchers/in_json_path"

module RSpec
  module Rest
    module Matchers
      class IncludeJson < RSpec::Matchers::BuiltIn::Include
        include RSpec::Rest::Matchers::JsonParser
        include RSpec::Rest::Matchers::JsonPath

        def initialize(expected_json, json_path = nil)
          @expected_json = expected_json
          super(@expected_json)
        end

        # Case: actual is Hash
        #   when expected is Hash and actual includes the expected Hash at least partially, returns true
        #     e.g) actual: {:foo => :bar, :hoge => :fuga} and expected: {:hoge => :fuga} #=> true
        #   but when expected value is included as child value, returns false
        #     e.g) actual: {:foo => :bar, :hoge => {:fuga  => :piyo}} and expected: {:fuga  => :piyo} #=> false
        # Case: actual is Array
        #   when expected is Array and actual includes the expected at least partially, returns true
        #     e.g) actual: [1,2,3] and expected: [1,2] #=> true
        #   when expected is not Array and actual includes the expected value as item, returns true
        #     e.g) actual: [1,2,3] and expected: 1 #=> true
        # In above cases, if child value is Array of Hash, same match logic is applied recursively.
        #
        # Other cases:
        #   when expected equals to actual returns true
        #     e.g) actual: 1 and expected: 1 #=> true
        def matches?(actual)
          @actual = parse_json(actual)
          @expected = parse_json(@expected_json)
          json_match?(@actual, @expected)
        end

        private
        def json_match?(actual, expected)
          case actual
          when Array
            if expected.is_a?(Array)
              if expected.all?{|item| array_partial_include?(actual, item)}
                return true
              end
            end
            array_partial_include?(actual, expected)
          when Hash
            hash_partial_include?(actual, expected)
          else
            actual == expected
          end
        end

        def hash_partial_include?(actual_hash, expected_hash)
          unless actual_hash.is_a?(Hash) and expected_hash.is_a?(Hash)
            return false
          end

          expected_hash.all? do |key, value|
            if actual_hash.key?(key)
              case expected_hash[key]
              when Hash
                hash_partial_include?(actual_hash[key], expected_hash[key])
              when Array
                expected_hash[key].all?{|val| array_partial_include?(actual_hash[key], val)}
              else
                expected_hash[key] == actual_hash[key]
              end
            else
              false
            end
          end
        end

        def array_partial_include?(actual_array, expected_item)
          actual_array.any? do |actual_item|
            case actual_item
            when Hash
              # actual: [{key => value},...]
              # expected item is Hash and is included partially in this actual_item?
              expected_item.is_a?(Hash) && hash_partial_include?(actual_item, expected_item)
            when Array
              # actual: [[value],...]
              # all expected items are included in this actual_item?
              expected_item.is_a?(Array) && expected_item.all?{|e| array_partial_include?(actual_item, e)}
            else actual_item == expected_item
            end
          end
        end
      end
    end
  end
end

