
module RSpec
  module Rest
    module EnableSeparationLogger
      def self.included(config)
        config.before(:each) do
          if RSpec.respond_to?(:current_example)
            example = RSpec.current_example
            groups = example.example_group.to_s.gsub("RSpec::ExampleGroups::", "").split("::").map{|klass|
              klass.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
            }
            group_path = File.join(*groups)
            path =  File.join("log", group_path, "#{example.metadata[:description].downcase.gsub(/\s+\/?/, "_").gsub(/\//, "_").gsub("::", "/")}")
          else
            path =  File.join("log", "#{example.full_description.downcase.gsub(/\s+\/?/, "_").gsub(/\//, "_").gsub("::", "/")}")
          end

          unless File.exists?(File.dirname(path))
            FileUtils.mkdir_p(File.dirname(path))
          end
          @__log_file__ = File.open("#{path}.log", "w")
          RSpec.configuration.logger = ::Logger.new(@__log_file__)
          RSpec.configuration.logger.info("start '#{example.full_description}'")
        end

        config.after(:each) do
          if @__log_file__ && !@__log_file__.closed?
            RSpec.configuration.logger.info("complete")
            @__log_file__.close
          end
        end
      end
    end

    module Logger
      def logger
        RSpec.configuration.logger
      end
    end
  end
end
