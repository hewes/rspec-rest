require "net/https"
require "yaml"
require "rspec/rest/http/request"
require "rspec/rest/http/response"

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
          do_request(:get, path, options, &bk)
        end

        def post(path, options = {}, &bk)
          do_request(:post, path, options, &bk)
        end

        def put(path, options = {}, &bk)
          do_request(:put, path, options, &bk)
        end

        def delete(path, options = {}, &bk)
          do_request(:delete, path, options, &bk)
        end

        def default_request
          yield __build_request__
        end

        def response
          @__response__
        end

        private
        def do_request(method, path, options)
          request = __build_request__
          yield request if block_given?
          uri = __build_uri__(path, options[:server] || request.server)
          http_request = HTTP.const_get(method.to_s.capitalize).new(uri.path, __build_http_headers__(request))

          if request.auth
            request.auth.inject_auth(http_request)
          end

          if request.body
            http_request.body = request.body
          end

          # TODO: https particular case
          response = Net::HTTP.new(uri.host, uri.port) do |http|
            http.request(http_request)
          end
          @__response__ = RSpec::Rest::Http::Response.new(response)
        end

        # @return [RSpec::Rest::Http::Request]
        def __build_request__
          @__request__ ||= RSpec::Rest::Http::Request.new
        end

        def __build_uri__(path, server = nil)
          configs = __load_server_configuraitons__
          if server
            config = configs[server]
            raise RSpec::Rest::ConfigurationError.new("#{server} not found in configuration") unless config
          else
            if configs.keys.size != 1
              config = configs.values.first
            else
              config = configs.values.find{ |config| config[:default]}
              raise RSpec::Rest::ConfigurationError.new("server not specified and default server not found") unless config
            end
          end
          uri_string = %Q(#{config[:scheme] || "http"}://#{config[:address]}:#{config[:port] || 80}/#{config[:base_path]}#{path})
          URI.parse(uri_string)
        end

        def __build_http_headers__(rest_request)
          headers = {}
          if rest_request.content_type
            headers["Content-Type"] = rest_request.content_type
          end

          if rest_request.accept
            headers["Accept"] = rest_request.accept
          end
          headers.merge(request.headers)
        end

        def __load_server_configuraitons__
          $__server_configurations__  || YAML.load(RSpec.configuration.config_path + "/servers.yml")
        end
      end
    end
  end
end

