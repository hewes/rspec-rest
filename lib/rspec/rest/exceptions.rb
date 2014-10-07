
module RSpec
  module Rest
    class ConfigurationError < Exception
      def initialize(message)
        super(message)
      end
    end

    class AuthenticationMechanismInvalid < Exception
      def initialize(auth_name, mechanism)
        super("specified mechanism '#{mechanism}' for #{auth_name} is not supported")
      end
    end

    class AuthenticationInformatoinNotFound < Exception
      def initialize(auth_name)
        super("#{auth_name} is not found in authentications.yml")
      end
    end

    class AuthenticationFailed < Exception
      def initialize(auth_name, message)
        super("Authentication failed. definition of #{auth_name} may be invalid. server response: #{message}")
      end
    end

    class KeystoneDefinitionNotFound < Exception
      def initialize(server_name)
        super("#{server_name} not found in definition file")
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

