require "json"

module RSpec
  module Rest
    module Matchers
      module JsonParser
        def parse_json(arg)
          case arg
          when Hash,Array then JSON.parse(arg.to_json)
          when String then JSON.parse(arg)
          when Integer,NilClass  then arg
          else raise ArgumentError.new("can not parse specified value")
          end
        end
      end
    end
  end
end
