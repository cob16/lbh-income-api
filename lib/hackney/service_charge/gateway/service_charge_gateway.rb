require 'uri'
require 'uk_postcode'
require 'net/http'
require "#{Rails.root}/lib/hackney/service_charge/exceptions/service_charge_api_exception"

module Hackney
  module ServiceCharge
    module Gateway
      class ServiceChargeGateway
        include HTTParty
        format :json

        def initialize(host:, api_key:)
          self.class.base_uri host
          @options = {
            headers: {
              'X-Api-Key': api_key,
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            }
          }
        end

        def get_cases_by_refs(refs)
          return [] if refs.empty?
          response = self.class.get("/api/v1/cases?tenancy_refs=#{URI.encode_www_form_component(refs)}", @options)

          raise Hackney::ServiceCharge::Exceptions::ServiceChargeException, response unless response.success?

          body = JSON.parse(response.body)

          body['cases'].map do |sc_case|
            {
              tenancy_ref: sc_case.fetch('tenancy_ref'),
              correspondence_address_1: sc_case.fetch('correspondence_address_1'),
              correspondence_address_2: sc_case.fetch('correspondence_address_2'),
              correspondence_address_3: sc_case.fetch('correspondence_address_3'),
              correspondence_postcode: sc_case.fetch('correspondence_postcode'),
              property_address: sc_case.fetch('property_address'),
              payment_ref: sc_case.fetch('payment_ref'),
              balance: sc_case.fetch('balance'),
              collectable_arrears_balance: sc_case.fetch('collectable_arrears_balance'),
              lba_expiry_date: sc_case.fetch('lba_expiry_date'),
              original_lease_date: sc_case.fetch('original_lease_date'),
              date_of_current_purchase_assignment: sc_case.fetch('date_of_current_purchase_assignment'),
              original_Leaseholders: sc_case.fetch('original_Leaseholders'),
              full_names_of_current_lessees: sc_case.fetch('full_names_of_current_lessees'),
              previous_letter_sent: sc_case.fetch('previous_letter_sent'),
              arrears_letter_1_date: sc_case.fetch('arrears_letter_1_date'),
              international: international?(sc_case.fetch('correspondence_postcode'))
            }
          end
        end

        private

        def international?(postcode)
          !UKPostcode.parse(postcode).valid?
        end
      end
    end
  end
end
