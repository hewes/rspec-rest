
module RSpec
  module Rest
    module Logger
      def logger
        RSpec.configuration.logger
      end
    end
  end
end
