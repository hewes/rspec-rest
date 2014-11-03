require "rspec/rest/http/mime"

module RSpec
  module Rest
    module Http
      class Request

        def initialize(default_request = nil)
          @content_mime_type = default_request.content_mime_type rescue nil
          @content_charset = default_request.content_charset rescue nil
          @content_type = default_request.content_type rescue nil
          @body = default_request.body rescue nil
          @accept = default_request.instance_variable_get(:@accept) rescue nil
          @option_headers = default_request.headers rescue {}
          @auth = default_request.auth rescue nil
          @server = default_request.server rescue nil
        end

        attr_writer :content_type, :accept
        attr_accessor :content_mime_type, :content_charset, :body, :server, :auth
        attr_reader :option_headers

        def content_type
          @content_type || Mime.format_content_type(@content_mime_type, @content_charset)
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
end

