module Hackney
  module Tenancy
    module Exceptions
      class TenancyApiException < StandardError
        attr_reader :response
        def initialize(response)
          super
          @response = response
        end

        def to_s
          "[Tenancy API error: Received #{response&.code} response] #{super}"
        end
      end
    end
  end
end
