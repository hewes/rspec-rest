require "rspec/rest/http/mime"
require "forwardable"

module RSpec
  module Rest
    module Http
      class Response
        extend Forwardable

        def initialize(http_response)
          @http_response = http_response
        end
        attr_reader :http_response

        def_delegators :@http_response, :code, :body, :message, :header

        def content_mime_type
          content_type.split(";").first
        end

        def content_charset
          content_type.split(";")[1]
        end

        def content_type
          @http_response["Content-Type"]
        end

        def location
          @http_response["Location"]
        end

        def headers
          headers = {}
          @http_response.each_key do |key|
            headers[key] = @http_response[key]
          end
          return headers
        end
      end
    end
  end
end

