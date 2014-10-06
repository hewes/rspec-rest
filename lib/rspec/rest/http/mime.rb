module RSpec
  module Rest
    module Http
      module Mime
        TypeMap = {
          :text       => "text/plain",
          :html       => "text/html",
          :json       => "application/plain",
          :xml        => "application/xml",
          :binary     => "application/octet-stream",
          :pdf        => "application/pdf",
          :js         => "application/javascript",
          :javascript => "application/javascript",
        }

        CharMap = {
          "utf8"      => "utf-8",
          "utf-8"     => "utf-8",
          "utf_8"     => "utf-8",
          "shift-jis" => "shift_jis",
          "sjis"      => "sjis",
          "eucjp"     => "euc-jp",
          "euc_jp"    => "euc-jp",
        }

        def foramt_content_type(mime_type, charset)
          mt = format_mime_type(mime_type)
          cs = RSpec.configuration.use_synonym ? (charset && "; #{CharMap[charset.to_s.downcase] || charset}") : charset
          %Q(#{mt}#{cs})
        end

        def format_mime_type(mime_type)
          if RSpec.configuration.use_synonym
            TypeMime[mime_type] || mime_type
          else
            mime_type
          end
        end
      end
    end
  end
end

