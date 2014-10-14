require "json"

module RSpec
  module Rest
    module Matchers
      class IncludeJson < RSpec::Matchers::BuiltIn::Include

        module PartialInclude
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

          def parse_json(arg)
            case arg
            when Hash,Array then JSON.parse(arg.to_json)
            when String then JSON.parse(arg)
            when Integer,NilClass  then arg
            else raise ArgumentError.new("can not parse specified value")
            end
          end
        end
        include PartialInclude

        def initialize(expected_json, json_path = nil)
          @expected_json = expected_json
          super(@expected_json)
        end

        def matches?(actual)
          @actual = parse_json(actual)
          @expected = parse_json(@expected_json)
          json_match?(@actual, @expected)
        end

        class IncludeInJsonPath
          include PartialInclude

          def initialize(expected, json_path)
            @expected = parse_json(expected)
            @json_path = json_path
            @validated_json_path = []
          end

          def matches?(actual)
            @actual = actual
            @actual = parse_json(actual)
            target = @json_path.split("/").inject(@actual) do |result, key|
              @validated_json_path << key
              unless result.key?(key)
                @not_found_in_json_path = true
                return false
              end
              result[key]
            end
            json_match?(target, @expected)
          end

          def failure_message
            if @not_found_in_json_path
              "#{@actual.inspect} does not have json path #{@validated_json_path.join('/').inspect}"
            else
              "#{@actual.inspect} does not include #{@expected.inspect} in #{@json_path}"
            end
          end
        end

        def in(json_path)
          IncludeInJsonPath.new(@expected_json, json_path)
        end
      end
    end
  end
end
