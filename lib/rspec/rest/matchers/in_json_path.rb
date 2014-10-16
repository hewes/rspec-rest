require "rspec/rest/matchers/json_parser"

module RSpec
  module Rest
    module Matchers
      module JsonPath
        def in(json_path)
          InJsonPathMatcher.new(self, json_path)
        end

        class InJsonPathMatcher
          include RSpec::Rest::Matchers::JsonParser

          def initialize(parent_matcher, json_path)
            @parent_matcher = parent_matcher
            @json_path = json_path
            @validated_json_path = []
          end

          def matches?(actual)
            @actual = actual
            target = @json_path.split("/").inject(parse_json(actual)) do |result, key|
              @validated_json_path << key
              unless result.key?(key)
                @not_found_in_json_path = true
                return false
              end
              result[key]
            end
            @parent_matcher.matches?(target)
          end

          def failure_message
            if @not_found_in_json_path
              "#{@actual.inspect} does not have json path #{@validated_json_path.join('/').inspect}"
            else
              @parent_matcher.failure_message + "(#{@json_path} in #{@actual})"
            end
          end
        end
      end
    end
  end
end
