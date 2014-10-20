require "ostruct"

module RSpec
  module Rest
    module Template
      class ErbTemplate
        class ErbParamWrapper < OpenStruct
          def initialize(erb, params)
            @erb = erb
            super(params)
          end

          def render
            @erb.result(binding).chomp
          end
        end

        def initialize(file_path)
          require "erb"
          @file_path = file_path
          @erb = ERB.new(File.read(file_path))
        end

        def with(params = {})
          ErbParamWrapper.new(@erb, params).render
        end

        def to_s
          begin
            @erb.result.chomp
          rescue NameError => ex
            raise RSpec::Rest::TemplateRenderError.new(@file_path, "param #{ex.name} required to render")
          end
        end
      end

      EngineMap = {
        ".erb" => ErbTemplate
      }

      module Helpers
        def template(path)
          $__temaplate_caches__ ||= {}
          unless $__temaplate_caches__.key?(path)
            file_path = RSpec.configuration.template_path + "/" + path.to_s
            unless File.readable?(file_path)
              file_path = file_path + "." + RSpec.configuration.default_template_engine.to_s
              unless File.readable?(file_path)
                raise RSpec::Rest::TemplateMissing.new(file_path)
              end
            end

            ext = File.extname(file_path)
            template_engine = EngineMap[ext || RSpec.configuration.default_template_engine.to_s]
            unless template_engine
              raise RSpec::Rest::TemplateEngineNotSupported.new(ext)
            end
            $__temaplate_caches__[path] = template_engine.new(file_path)
          end
          $__temaplate_caches__[path]
        end
      end
    end
  end
end

