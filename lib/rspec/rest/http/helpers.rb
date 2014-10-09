require "net/https"
require "yaml"
require "rspec/rest/http/request"
require "rspec/rest/http/response"
require "rspec/rest/http/authentication"

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
        def do_request(method, path, options)
          @__request__ = RSpec::Rest::Http::Request.new(@__default_request__)
          yield @__request__ if block_given?

          config = __server_config__(options[:server] || @__request__.server)
          uri_string = %Q(#{config["scheme"] || "http"}://#{config["address"]}:#{config["port"] || 80}/#{config["base_path"]}#{path})
          begin
            uri = URI.parse(uri_string)
          rescue
            raise RSpec::Rest::ConfigurationError.new("#{uri_string} is invalid")
          end
          http_request = Net::HTTP.const_get(method.to_s.capitalize).new(uri.path, __build_http_headers__(@__request__))

          if @__request__.auth
            @__request__.auth.inject_auth(http_request)
          end

          if @__request__.body
            http_request.body = @__request__.body
          end

          # TODO: https particular case
          response = nil
          Net::HTTP.start(uri.host, uri.port) do |http|
            response = http.request(http_request)
          end
          @__response__ = RSpec::Rest::Http::Response.new(response)
        end

        def __server_config__(server_name)
          configs = __load_server_configuraitons__
          if server_name
            config = configs[server_name]
            unless config
              raise RSpec::Rest::ConfigurationError.new("#{server_name} not found in configuration")
            end
          else
            servers = configs.values
            config = (servers.size == 1 && servers.first) || servers.find{|server| server["default"]}
            unless config
              raise RSpec::Rest::ConfigurationError.new("server not specified and default server not found")
            end
          end
          return config
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

        def __load_server_configuraitons__
          return $__server_configurations__ if $__server_configurations__
          file_path = RSpec.configuration.config_path + "/servers.yml"
          $__server_configurations__  = RSpec::Rest::Util.load_yaml(file_path)
          unless $__server_configurations__.is_a?(Hash)
            raise RSpec::Rest::ConfigurationError.new("#{file_path} invalid format")
          end

          $__server_configurations__.each do |server_name, config|
            if !config.is_a?(Hash)
              raise RSpec::Rest::ConfigurationError.new("server configuration (#{server_name} in #{file_path}) is not a Hash")
            end
            ["address"].each do |key|
              unless config.key?(key)
                raise RSpec::Rest::ConfigurationError.new("#{key} not found in server configuration (#{server_name} in #{file_path}) ")
              end
            end
          end
          return $__server_configurations__
        end
      end
    end
  end
end

