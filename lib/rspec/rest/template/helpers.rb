require "ostruct"

module RSpec
  module Rest
    class Template

      class ErbTemplate < String
        class ErbParamWrapper < OpenStruct
          def initialize(erb, params)
            @erb = erb
            super(params)
          end

          def render
            @erb.result(binding).chomp
          end

          def to_s
            self.render
          end
        end

        def initialize(file_path)
          require "erb"
          @file_path = file_path
          body = File.read(@file_path).chomp
          @erb = ERB.new(body)
          super(body)
        end

        def with(params = {})
          ErbParamWrapper.new(@erb, params).render
        end
      end

      EngineMap = {
        ".erb" => ErbTemplate
      }

      class << self
        def load(path)
          @temaplate_caches ||= {}
          unless @temaplate_caches.key?(path)
            candidates = Dir.glob("#{RSpec.configuration.template_path}/**/#{path.to_s}*")
            case candidates.size
            when 0 then raise RSpec::Rest::TemplateMissing.new(path)
            when 1
            else raise RSpec::Rest::AmbiguousTemplatePath.new(path, candidates)
            end

            file_path = candidates.first
            unless File.readable?(file_path)
              raise RSpec::Rest::TemplateNotReadable.new(file_path)
            end

            ext = File.extname(file_path)
            template_engine = EngineMap[ext || RSpec.configuration.default_template_engine]
            unless template_engine
              raise RSpec::Rest::TemplateEngineNotSupported.new(ext)
            end
            @temaplate_caches[path] = template_engine.new(file_path)
          end
          @temaplate_caches[path]
        end
      end

      module Helpers
        def template(path)
          RSpec::Rest::Template.load(path)
        end
      end
    end
  end
end

