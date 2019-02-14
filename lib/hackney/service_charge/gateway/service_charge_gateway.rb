require 'uri'
require 'uk_postcode'
require 'net/http'
require "#{Rails.root}/lib/hackney/tenancy/exceptions/tenancy_api_exception"

module Hackney
  module ServiceCharge
    module Gateway
      class ServiceChargeGateway
        def initialize(host:, key:)
          @host = host
          @key = key
        end

        def get_cases_by_refs(refs)
          return [] if refs.empty?

          uri = URI("#{@host}/api/v1/cases?tenancy_refs=#{refs}")

          req = Net::HTTP::Get.new(uri)
          req['X-Api-Key'] = @key

          res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

          raise Hackney::Tenancy::Exceptions::TenancyApiException, res unless res.is_a? Net::HTTPSuccess

          body = JSON.parse(res.body)

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
              international: is_international?(sc_case.fetch('correspondence_postcode'))
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
