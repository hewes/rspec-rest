require "json"

module RSpec
  module Rest
    module Matchers
      class IncludeJson < RSpec::Matchers::BuiltIn::Include
        def initialize(expected_json)
          @expected_hash = arg2hash(expected_json)
          super(@expected_hash)
        end

        def matches?(actual)
          @actual = arg2hash(actual)
          hash_match?(@actual, @expected_hash)
        end

        private
        def hash_match?(actual_hash, expected_hash)
          unless actual_hash.is_a?(Hash) and expected_hash.is_a?(Hash)
            return false
          end

          expected_hash.all? do |key, value|
            if actual_hash.key?(key)
              case expected_hash[key]
              when Hash then hash_match?(actual_hash[key], expected_hash[key])
              when Array then expected_hash[key].all?{|val| array_include?(actual_hash[key], val)}
              else expected_hash[key] == actual_hash[key]
              end
            else
              false
            end
          end
        end

        def array_include?(actual_array, expected_item)
          actual_array.any? do |actual_item|
            case actual_item
            when Hash then expected_item.is_a?(Hash) && hash_match?(actual_item, expected_item)
            when Array then expected_item.is_a?(Array) && expected_item.all?{|e| array_include?(actual_item, e)}
            else actual_item == expected_item
            end
          end
        end

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
