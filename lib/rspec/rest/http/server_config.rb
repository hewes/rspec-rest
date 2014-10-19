require "net/https"
require "rspec/rest/logger"

module RSpec
  module Rest
    module Http
      class ServerConfig
        include RSpec::Rest::Logger

        class << self
          def build(server_name = nil)
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
            return ServerConfig.new(config)
          end

          private
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
              ["host"].each do |key|
                unless config.key?(key)
                  raise RSpec::Rest::ConfigurationError.new("#{key} not found in server configuration (#{server_name} in #{file_path}) ")
                end
              end
            end
            return $__server_configurations__
          end
        end

        def initialize(config)
          @scheme = config["scheme"] || "http"
          @host = config["host"]
          @port = config["port"] || 80
          @base_path = config["base_path"]
          validate_path
        end

        def build_request_path(path)
          validate_path(path)
          return %Q(#{@base_path}#{path})
        end

        def send_request(req)
          logger.info(self.to_s)

          log = "==============Request==================\n"
          log << "Header:\n"
          req.each_key do |key|
            log << %Q(  #{key}: #{req[key]}\n)
          end
          log << "Body: #{req.body}\n"
          log << "======================================="
          logger.info(log)

          res = Net::HTTP.start(@host, @port) do |http|
            if @scheme.downcase == "https"
              http.use_ssl = true
              if @config["ssl_verify"]
                http.verify_mode = OpenSSL::SSL::VERIFY_PEER
              else
                http.verify_mode = OpenSSL::SSL::VERIFY_NONE
              end
            end
            http.request(req)
          end

          log = "==============Response==================\n"
          log << "Header:\n"
          res.each_key do |key|
            log << %Q(  #{key}: #{res[key]}\n)
          end
          log << "Body: #{res.body}\n"
          log << "======================================="
          logger.info(log)

          return res
        end

        def to_s
          %Q(ServerConfig #{@scheme}://#{@host}:#{@port}/#{@base_path})
        end

        private
        def validate_path(path = nil)
          uri_string = %Q(#{@scheme}://#{@host}:#{@port}/#{@base_path}#{path})
          begin
            URI.parse(uri_string)
          rescue
            raise RSpec::Rest::ConfigurationError.new("#{uri_string} is invalid as URI")
          end
        end
      end
    end
  end
end

