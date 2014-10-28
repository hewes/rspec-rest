require "uri"

module RSpec
  module Rest
    module RestURLExampleGroup
      def http_method
        meth = rest_url_group[:description_args].first.split("\s")[0].downcase.to_sym
        case meth
        when :get,:post,:put,:delete,:head then meth
        else raise "invalid describe format for rest_url (#{rest_url_group[:description_args].first})"
        end
      end

      def request_path
        uri = URI.parse(rest_url_group[:description_args].first.split(/\s+/)[1])
        path = uri.path
        path.scan(/:[^\/]+/).uniq.each do |pattern|
          var = :"@#{pattern.sub(/^:/, "")}"
          unless instance_variable_defined?(var)
            raise "instance variable #{pattern} not defined"
          end
          path.gsub!(pattern, instance_variable_get(var))
        end
        return path
      end

      def rest_url_group
        if RSpec.respond_to?(:current_example)
          example_group = RSpec.current_example.metadata[:example_group]
          while example_group.key?(:parent_example_group)
            example_group = example_group[:parent_example_group]
          end
        else
          example_group = example.metadata
          while example_group.key?(:example_group)
            example_group = example_group[:example_group]
          end
        end
        return example_group
      end
    end
  end
end

