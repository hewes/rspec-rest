
module RSpec
  module Rest
    class ConfigurationError < Exception
      def initialize(message)
        super(message)
      end
    end

    class TemplateMisssing < Exception
      def initialize(template_path)
        super("#{template_path} not found")
      end
    end

    class TemplateRenderError < Exception
      def initialize(template, reason)
        super("Failed to render #{template}. reason: #{reason}")
      end
    end

    class TemplateEngineNotSupported < Exception
      def initialize(template_engine)
        super("#{template_engine} not supported")
      end
    end
  end
end

