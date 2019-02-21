require 'uri'
require "#{Rails.root}/lib/hackney/service_charge/exceptions/service_charge_api_exception"

module Hackney
  module ServiceCharge
    module Gateway
      class ServiceChargesAdapter
        attr_reader :response
        attr_writer :api_key
        include HTTParty
        format :json

        def initialize(host:, api_key:)
          self.class.base_uri host
          self.api_key = api_key
        end

        def request(query)
          endpoint = '/api/v1/cases'
          headers = {
            'X-Api-Key': api_key,
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          }

          @response = self.class.get(endpoint + '?' + query,
                                     headers: headers)

          raise Hackney::ServiceCharge::Exceptions::ServiceChargeException, @response unless @response.success?

          JSON.parse(@response.body)
        end

        private

        attr_reader :api_key
      end
    end
  end
end
