require "uri"

module RSpec
  module Rest
    module RestURLExampleGroup
      def http_method
        meth = top_level_group[:description_args].first.split("\s")[0].downcase.to_sym
        case meth
        when :get,:post,:put,:delete,:head then meth
        else raise "invalid describe format for rest_url (#{top_level_group[:description_args].first})"
        end
      end

      def request_path
        uri = URI.parse(top_level_group[:description_args].first.split(/\s+/)[1])
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

      def top_level_group
        metadata = example.metadata
        while metadata.key?(:example_group)
          metadata = metadata[:example_group]
        end
        return metadata
      end
    end
  end
end

