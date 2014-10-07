require "json"
require "net/https"

module RSpec
  module Rest
    module Http
      class Authentication

        DriverMap = {
          "basic" => Basic,
          "keystone_v2" => Keystone_v2,
          "keystone_v3" => Keystone_v3,
        }

        def self.build(auth_name)
          @__authentications__ = {}
          return @__authentications__[auth_name] if @__authentications__[auth_name]
          @__file_cache__ ||= YAML.load(RSpec.configuration.config_path + "/authentications.yml")

          auth_info = @__file_cache__[auth_name]
          unless auth_info
            raise RSpec::Rest::AuthenticationInformatoinNotFound.new(auth_name)
          end

          driver = DriverMap[auth_info[:driver]]
          unless driver
            raise RSpec::Rest::AuthenticationMechanismInvalid.new(auth_name, auth_info[:driver])
          end
          @__authentications__[auth_name] = driver.new(auth_name, auth_info)
        end

        class Basic
          def initialize(auth_name, auth_info)
            @auth_name = auth_name
            @auth_info = auth_info
          end

          def inject_auth(http_request)
            # TODO: implement
          end
        end

        class Keystone
          def initialize(auth_name, auth_info)
            $__keystones__ ||= YAML.load(RSpec.configuration.config_path + "/keystones.yml")
            @auth_info = auth_info
            @auth_name = auth_name
            @expire_time = nil
            authenticate
          end

          def inject_auth(http_request)
            http_request["X-Auth-Token"] = token
          end

          private
          def token
            if (Time.now + 60) > @expire_time
              authenticate
            end
            @token
          end

          def base_uri
            target = $__keystones__[@auth_info[:server]]
            unless target
              raise RSpec::Rest::KeystoneDefinitionNotFound.new(@auth_info[:server])
            end
            %Q(#{target[:scheme] || "http"}://#{target[:address]}:#{target[:port] || 5000}#{target[:base_path] || nil})
          end
        end

        class Keystone_v2 < Keystone
          def authenticate
            uri_string = base_uri + "/v2.0/tokens"
            uri = URI.parse(uri_string)

            request = HTTP::Post.new(uri.path, "Content-Type" => "application/json")
            request.body = {
              :auth  =>  {
                :tenantName => @auth_info[:tenant],
                :passwordCredentials => {
                  :username => @auth_info[:user],
                  :password  => @auth_info[:pass]
                }
              }
            }.to_json

            # TODO: https particular case
            response = Net::HTTP.new(uri.host, uri.port) do |http|
              http.request(http_request)
            end

            if response.code == 201
              token_info = JSON.pasre(response.body)["access"]["token"]
              @token = token_info["id"]
              @expire_time = Time.parse(token_info["expires"])
            else
              raise RSpec::Rest::AuthenticationFailed.new(@auth_name, response.body)
            end
          end
        end

        class Keystone_v3 < Keystone
          def authenticate
            uri_string = base_uri + "/v3/tokens"
            uri = URI.parse(uri_string)

            request = HTTP::Post.new(uri.path, "Content-Type" => "application/json")
            auth = {
              :auth  =>  {
                :identity => {
                  :methods => ["passsword"],
                  :password => {
                    :user => {
                      :name => @auth_info[:user],
                      :domain => {:id => @auth_info[:domain]},
                      :password => @auth_info[:pass],
                    }
                  }
                }
              }
            }

            if @auth_info[:project]
              auth[:scope] = {
                :project => {
                  :name => @auth_info[:project],
                  :domain => {:id => @auth_info[:domain]},
                }
              }
            end

            request.body = auth.to_json

            # TODO: https particular case
            response = Net::HTTP.new(uri.host, uri.port) do |http|
              http.request(http_request)
            end

            if response.code == 201
              token_info = JSON.pasre(response.body)["token"]
              @token = response.header["X-Subject-Token"]
              @expire_time = Time.parse(token_info["expires_at"])
            else
              raise RSpec::Rest::AuthenticationFailed.new(@auth_name, response.body)
            end
          end
        end
      end
    end
  end
end

