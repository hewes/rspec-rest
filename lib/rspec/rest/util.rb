
module RSpec
  module Rest
    module Util
      def load_yaml(file_path)
        unless File.readable?(file_path)
          raise RSpec::Rest::FileNotReadable.new(file_path)
        end
        YAML.load(File.read(file_path))
      end
      module_function :load_yaml

      def logger
        RSpec.configuration.logger
      end
    end
  end
end
