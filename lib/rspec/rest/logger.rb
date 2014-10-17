
module RSpec
  module Rest
    module EnableSeparationLogger
      def self.included(config)
        config.before(:each) do
          path =  "log/#{example.full_description.downcase.gsub("::", "/").gsub(/\s+/, "_")}"
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
