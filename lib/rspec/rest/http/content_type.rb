require "rspec/rest/http/mime"

module RSpec
  module Rest
    module Http
      module ContentType
        include RSpec::Rest::Http::Mime

        def format_content_type(mime_type, charset)
          mt = format_mime_type(mime_type)
          cs = RSpec.configuration.use_synonym ? (charset && "; #{CharMap[charset.to_s.downcase] || charset}") : charset
          %Q(#{mt}#{cs})
        end

        def split_content_type(content_type)
          content_type.split(";")
        end
      end
    end
  end
end

