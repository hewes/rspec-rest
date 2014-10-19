require "net/https"
require "yaml"
require "rspec/rest/http/request"
require "rspec/rest/http/response"
require "rspec/rest/http/authentication"
require "rspec/rest/http/server_config"

module RSpec
  module Rest
    module Http
      module Helpers
        module ClassMethods
          def with_authentication(auth_name)
            before(:each) do
              default_request do |req|
                req.auth = RSpec::Rest::Http::Authentication.build(auth_name)
              end
            end
          end
        end

        def self.included(child)
          child.extend(ClassMethods)
        end

        def get(path, options = {}, &bk)
          __do_request__(:get, path, options, &bk)
        end

        def post(path, options = {}, &bk)
          __do_request__(:post, path, options, &bk)
        end

        def put(path, options = {}, &bk)
          __do_request__(:put, path, options, &bk)
        end

        def delete(path, options = {}, &bk)
          __do_request__(:delete, path, options, &bk)
        end

        def default_request
          @__default_request__ ||= RSpec::Rest::Http::Request.new
          if block_given?
            yield @__default_request__
          end
          @__default_request__
        end

        def request
          @__request__
        end

        def response
          @__response__
        end

        private
        def __do_request__(method, path, options)
          @__request__ = RSpec::Rest::Http::Request.new(@__default_request__)
          yield @__request__ if block_given?

          server = ServerConfig.build(@__request__.server)

          request_path = server.build_request_path(path)
          http_request = Net::HTTP.const_get(method.to_s.capitalize).new(request_path, __build_http_headers__(@__request__))

          if @__request__.auth
            @__request__.auth.inject_auth(http_request)
          end

          if @__request__.body
            http_request.body = @__request__.body
          end

          http_response = server.send_request(http_request)

          @__response__ = RSpec::Rest::Http::Response.new(http_response)
        end

        def __build_http_headers__(rest_request)
          headers = {}
          if rest_request.content_type
            headers["Content-Type"] = rest_request.content_type
          end

          if rest_request.accept
            headers["Accept"] = rest_request.accept
          end
          headers.merge(rest_request.headers)
        end
      end
    end
  end
end

