require "json"
require "net/https"
require "time"

module RSpec
  module Rest
    module Http
      class Authentication

        def self.build(auth_name)
          @__authentications__ = {}
          return @__authentications__[auth_name] if @__authentications__[auth_name]
          @__file_cache__ ||= RSpec::Rest::Util.load_yaml(RSpec.configuration.config_path + "/authentications.yml")

          auth_info = @__file_cache__[auth_name]
          unless auth_info
            raise RSpec::Rest::AuthenticationInformatoinNotFound.new(auth_name)
          end

          driver = DriverMap[auth_info["mechanism"]]
          unless driver
            raise RSpec::Rest::AuthenticationMechanismInvalid.new(auth_name, auth_info["mechanism"])
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
            @auth_info = auth_info
            @auth_name = auth_name
            @server_config = RSpec::Rest::Http::ServerConfig.build(@auth_info["server"], "keystones.yml")
            @expire_time = nil
            @tenant_id = nil
          end
          attr_reader :tenant_id

          def inject_auth(http_request)
            http_request["X-Auth-Token"] = token
          end

          private
          def token
            if @token
              if (Time.now + 60) > @expire_time
                authenticate
              end
            else
              authenticate
            end
            @token
          end
        end

        class Keystone_v2 < Keystone
          def authenticate
            request_path = @server_config.build_request_path("/v2.0/tokens")
            http_request = Net::HTTP::Post.new(request_path, "Content-Type" => "application/json")
            http_request.body = {
              :auth  =>  {
                :tenantName => @auth_info["tenant"],
                :passwordCredentials => {
                  :username => @auth_info["user"],
                  :password  => @auth_info["pass"]
                }
              }
            }.to_json

            response = @server_config.send_request(http_request)

            if [200, 201].include?(response.code.to_i)
              token_info = JSON.parse(response.body)["access"]["token"]
              @token = token_info["id"]
              @expire_time = Time.parse(token_info["expires"])
              @tenant_id = token_info["tenant"]["id"]
            else
              raise RSpec::Rest::AuthenticationFailed.new(@auth_name, "response(code: #{response.code}, body: #{response.body})")
            end
          end
        end

        class Keystone_v3 < Keystone
          def authenticate
            request_path = @server_config.build_request_path("/v3/tokens")
            http_request = Net::HTTP::Post.new(request_path, "Content-Type" => "application/json")
            auth = {
              :auth  =>  {
                :identity => {
                  :methods => ["passsword"],
                  :password => {
                    :user => {
                      :name => @auth_info["user"],
                      :domain => {:id => @auth_info["domain"]},
                      :password => @auth_info["pass"],
                    }
                  }
                }
              }
            }

            if @auth_info["project"]
              auth[:scope] = {
                :project => {
                  :name => @auth_info["project"],
                  :domain => {:id => @auth_info["domain"]},
                }
              }
            end
            http_request.body = auth.to_json

            response = @server_config.send_request(http_request)

            if [200, 201].include?(response.code.to_i)
              token_info = JSON.parse(response.body)["token"]
              @token = response.header["X-Subject-Token"]
              @expire_time = Time.parse(token_info["expires_at"])
              @tenant_id = token_info["project"]["id"]
            else
              raise RSpec::Rest::AuthenticationFailed.new(@auth_name, "response(code: #{response.code}, body: #{response.body})")
            end
          end
        end

        DriverMap = {
          "basic" => Basic,
          "keystone_v2" => Keystone_v2,
          "keystone_v3" => Keystone_v3,
        }
      end
    end
  end
end

