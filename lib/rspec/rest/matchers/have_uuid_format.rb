require "json"
require "rspec/rest/matchers/in_json_path"

module RSpec
  module Rest
    module Matchers
      module Pattern
        def hex
          /[0-9a-f]/
        end
      end

      # UUID
      class HaveUuidFormat
        include RSpec::Rest::Matchers::JsonPath
        include Pattern

        def matches?(actual)
          @actual = actual
          actual.to_s.gsub('-', '').downcase =~ /\A#{hex}{32}\Z/
        end

        def failure_message
          "#{@actual} is not UUID format"
        end
      end

      # GUID
      class HaveGuidFormat
        include Pattern
        include RSpec::Rest::Matchers::JsonPath

        def matches?(actual)
          @actual = actual
          actual.to_s.downcase =~ /\A#{hex}{8}-#{hex}{4}-#{hex}{4}-#{hex}{4}-#{hex}{12}\Z/
        end

        def failure_message
          "#{@actual} is not GUID format"
        end
      end
    end
  end
end

