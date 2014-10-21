require "rspec/rest/matchers/in_json_path"

module RSpec
  module Rest
    module Matchers
      class Contain < RSpec::Matchers::BuiltIn::BaseMatcher
        include RSpec::Rest::Matchers::JsonPath

        def initialize(expected, mode = nil)
          @expected = expected
          unless @expected.is_a?(Fixnum)
            raise ArgumentError.new("Contain matcher required Fixnum for initialize. but provided #{expected}")
          end
          @matche_mode = mode
        end

        def matches?(actual)
          unless @match_mode && @valid
            @message = "Contain matcher requires call with #items"
            return false
          end

          case @match_mode
          when :same,:at_least,:at_most
            unless actual.respond_to?(:size)
              @message = "expect #{actual} to respondd to size but not"
              return false
            end
          end

          case @match_mode
          when :same
            @message = "expect #{actual} to contain #{@expected} items. but actual is #{actual.size}"
            return actual.size == @expected
          when :at_least
            @message = "expect #{actual} to contain at least #{@expected} items actual is #{actual.size}"
            return actual.size >= @expected
          when :at_most
            @message = "expect #{actual} to contain at most #{@expected} items actual is #{actual.size}"
            return actual.size <= @expected
          else
            @message = "Contain matcher is invalid match_mode: #{@match_mode}"
            return false
          end
        end

        def failure_message
          @message
        end

        # expect(value).to contain(3).items
        def items
          @match_mode ||= :same
          @valid = true
          self
        end
      end
    end
  end
end
