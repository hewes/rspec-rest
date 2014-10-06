require "rspec/rest/http/mime"

module RSpec
  module Rest
    class Request

      def initialize
        @content_mime_type = :text
        @accept = :text
        @content_charset = nil
        @content_type = nil
        @body = nil
        @accept = nil
        @option_headers = {}
        @auth = nil
        @server = nil
      end

      attr_writer :content_mime_type, :content_type
      attr_accessor :content_charset, :body, :server
      attr_reader :option_headers

      def content_type
        @content_type || Mime.foramt_content_type(@mime_type, @charset)
      end

      def accept
        Mime.format_mime_type(@accept)
      end

      def headers
        @option_headers
      end
    end
  end
end

