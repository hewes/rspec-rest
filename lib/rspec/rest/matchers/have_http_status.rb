require "net/http"

module RSpec
  module Rest
    module Matchers
      class HaveHttpStatus
        def initialize(expected)
          @expected =  case expected
                       when Symbol then symbol2num(expected)
                       when String then expected.to_i
                       when Fixnum then expected
                       else raise ArgumentError, "expected value must be Symbol or Fixnum"
                       end
          @actual = nil
        end

        # @param [Object] response object providing an http code to match
        # @return [Boolean] `true` if the numeric code matched the `response` code
        def matches?(response)
          if response.respond_to?(:code)
            @actual = response.code
            @expected == @actual.to_i
          else
            false
          end
        end

        private
        # same as rails's one
        def symbol2num(symbol)
          case symbol
          when :continue                        then 100
          when :switching_protocols             then 101
          when :processing                      then 102
          when :ok                              then 200
          when :created                         then 201
          when :accepted                        then 202
          when :non_authoritative_information   then 203
          when :no_content                      then 204
          when :reset_content                   then 205
          when :partial_content                 then 206
          when :multi_status                    then 207
          when :im_used                         then 226
          when :multiple_choices                then 300
          when :moved_permanently               then 301
          when :found                           then 302
          when :see_other                       then 303
          when :not_modified                    then 304
          when :use_proxy                       then 305
          when :temporary_redirect              then 307
          when :bad_request                     then 400
          when :unauthorized                    then 401
          when :payment_required                then 402
          when :forbidden                       then 403
          when :not_found                       then 404
          when :method_not_allowed              then 405
          when :not_acceptable                  then 406
          when :proxy_authentication_required   then 407
          when :request_timeout                 then 408
          when :conflict                        then 409
          when :gone                            then 410
          when :length_required                 then 411
          when :precondition_failed             then 412
          when :request_entity_too_large        then 413
          when :request_uri_too_long            then 414
          when :unsupported_media_type          then 415
          when :requested_range_not_satisfiable then 416
          when :expectation_failed              then 417
          when :unprocessable_entity            then 422
          when :locked                          then 423
          when :failed_dependency               then 424
          when :upgrade_required                then 426
          when :internal_server_error           then 500
          when :not_implemented                 then 501
          when :bad_gateway                     then 502
          when :service_unavailable             then 503
          when :gateway_timeout                 then 504
          when :http_version_not_supported      then 505
          when :insufficient_storage            then 507
          when :not_extended                    then 510
          else raise ArgumentError, "invalid http status code"
          end
        end
      end
    end
  end
end

