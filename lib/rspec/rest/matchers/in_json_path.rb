require "rspec/rest/matchers/json_parser"

module RSpec
  module Rest
    module Matchers
      module JsonPath
        def in(json_path)
          InJsonPathMatcher.new(json_path, self)
        end

        def an_item_in(json_path)
          InJsonPathMatcher.new(json_path, self, :any)
        end

        def all_items_in(json_path)
          InJsonPathMatcher.new(json_path, :self, :all)
        end

        class InJsonPathMatcher
          include RSpec::Rest::Matchers::JsonParser

          def initialize(json_path, parent_matcher = nil, match_type = nil)
            @match_type = match_type
            @parent_matcher = parent_matcher
            @json_path = json_path
          end

          def matches?(actual)
            @actual = actual

            validated_json_path = []
            target = @json_path.split("/").inject(parse_json(actual)) do |result, key|
              validated_json_path << key
              case result
              when Hash
                unless result.key?(key)
                  @message = "#{@actual} does not have json path #{validated_json_path.join('/').inspect}"
                  return false
                end
                result[key]
              when Array
                ret_val = []
                result.each do |res|
                  unless res.key?(key)
                    @message = "any item #{@actual} does not have json path #{validated_json_path.join('/').inspect}"
                    return false
                  end
                  ret_val << res[key]
                end
                ret_val
              else
                @message = "#{@actual} does not have json path #{validated_json_path.join('/').inspect}"
                return false
              end
            end

            if @parent_matcher
              case @match_type
              when :any
                unless target.is_a?(Array)
                  @message ="expect #{target} in #{validated_json_path}} to be an Array"
                  return false
                end

                match = target.any? do |item| 
                  @parent_matcher.matches?(item)
                end
                @message = "#{@parent_matcher.failure_message} (and all others of #{target} too (#{@json_path} in #{@actual}))"
                return match
              when :all
                unless target.is_a?(Array)
                  @message ="expect #{target} in #{validated_json_path}} to be an Array"
                  return false
                end
                match = target.all? do |item| 
                  @parent_matcher.matches?(item)
                end
                @message = "#{@parent_matcher.failure_message} (#{@json_path} in #{@actual})"
                return match
              when nil
                @parent_matcher.matches?(target)
              end
            else
              return true
            end
          end

          def failure_message
            @message || %Q(#{@parent_matcher.failure_message} (#{@json_path} in #{@actual}))
          end
        end
      end
    end
  end
end
