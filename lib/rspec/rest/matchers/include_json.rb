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
          when Hash then hash_partial_include?(actual, expected)
          else actual == expected
          end
        end

        def hash_partial_include?(actual_hash, expected_hash)
          unless actual_hash.is_a?(Hash) and expected_hash.is_a?(Hash)
            return false
          end

          expected_hash.all? do |key, value|
            if actual_hash.key?(key)
              case expected_hash[key]
              when Hash then hash_partial_include?(actual_hash[key], expected_hash[key])
              when Array then expected_hash[key].all?{|val| array_partial_include?(actual_hash[key], val)}
              else expected_hash[key] == actual_hash[key]
              end
            else
              false
            end
          end
        end

        def array_partial_include?(actual_array, expected_item)
          actual_array.any? do |actual_item|
            case actual_item
            when Hash then expected_item.is_a?(Hash) && hash_partial_include?(actual_item, expected_item)
            when Array then expected_item.is_a?(Array) && expected_item.all?{|e| array_partial_include?(actual_item, e)}
            else actual_item == expected_item
            end
          end
        end
      end
    end
  end
end
