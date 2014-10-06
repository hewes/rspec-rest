require "rspec/rest/http/mime"
require "forwardable"

module RSpec
  module Rest
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

      def header
        @http_response
      end
    end
  end
end

