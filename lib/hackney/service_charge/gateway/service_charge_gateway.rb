require 'uk_postcode'
require_relative 'service_charge_adapter'
require "#{Rails.root}/lib/hackney/service_charge/exceptions/service_charge_api_exception"

module Hackney
  module ServiceCharge
    module Gateway
      class ServiceChargeGateway
        def initialize(host:, api_key:)
          @service_charge_adapter = ServiceChargesAdapter.new(
            host: host,
            api_key: api_key
          )
        end

        def get_cases_by_refs(refs)
          return [] if refs.empty?

          body = @service_charge_adapter.request("tenancy_refs=#{refs}")

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

        def fake_get_cases_by_refs(refs)
          pp refs.first
          raise Hackney::ServiceCharge::Exceptions::ServiceChargeException, refs if refs.first == '123'
          return [] if refs.empty?
          example_case(payment_ref: refs.first).map do |sc_case|
            {
              tenancy_ref: sc_case.fetch(:tenancy_ref),
              correspondence_address_1: sc_case.fetch(:correspondence_address_1),
              correspondence_address_2: sc_case.fetch(:correspondence_address_2),
              correspondence_address_3: sc_case.fetch(:correspondence_address_3),
              correspondence_postcode: sc_case.fetch(:correspondence_postcode),
              property_address: sc_case.fetch(:property_address),
              payment_ref: sc_case.fetch(:payment_ref),
              total_collectable_arrears_balance: sc_case.fetch(:balance),
              collectable_arrears_balance: sc_case.fetch(:collectable_arrears_balance),
              lba_expiry_date: sc_case.fetch(:lba_expiry_date),
              original_lease_date: sc_case.fetch(:original_lease_date),
              date_of_current_purchase_assignment: sc_case.fetch(:date_of_current_purchase_assignment),
              original_Leaseholders: sc_case.fetch(:original_Leaseholders),
              lessee_full_name: sc_case.fetch(:full_names_of_current_lessees).first,
              lessee_short_name: sc_case.fetch(:full_names_of_current_lessees).first,
              full_names_of_current_lessees: sc_case.fetch(:full_names_of_current_lessees),
              previous_letter_sent: sc_case.fetch(:previous_letter_sent),
              arrears_letter_1_date: sc_case.fetch(:arrears_letter_1_date),
              international: international?(sc_case.fetch(:correspondence_postcode))
            }
          end
        end

        private

        def international?(postcode)
          !UKPostcode.parse(postcode).valid?
        end

        def example_case(options = {})
          [{
            "tenancy_ref": options.fetch(:tenancy_ref, Faker::Lorem.characters(5)),
            "correspondence_address_1": options.fetch(:correspondence_address_1, Faker::Address.street_address),
            "correspondence_address_2": options.fetch(:correspondence_address_2, Faker::Address.secondary_address),
            "correspondence_address_3": options.fetch(:correspondence_address_3, Faker::Address.city),
            "correspondence_postcode": options.fetch(:correspondence_postcode, Faker::Address.zip_code),
            "property_address": options.fetch(:property_address, '1 Hillman St, London, E8 1DY'),
            "payment_ref": options.fetch(:payment_ref, Faker::Number.number(10)),
            "balance": options.fetch(:balance, Faker::Number.decimal(4, 2)),
            "collectable_arrears_balance": options.fetch(:collectable_arrears_balance, Faker::Number.decimal(4, 2)),
            "lba_expiry_date": options.fetch(:lba_expiry_date, ''),
            "original_lease_date": options.fetch(:original_lease_date, Faker::Date.between(10.years.ago, Date.today)),
            "date_of_current_purchase_assignment": options.fetch(:date_of_current_purchase_assignment, Faker::Date.between(10.years.ago, Date.today)),
            "original_Leaseholders": options.fetch(:original_Leaseholders, Faker::Name.name),
            "full_names_of_current_lessees": options.fetch(:full_names_of_current_lessees, [Faker::Name.name]),
            "previous_letter_sent": options.fetch(:previous_letter_sent, ''),
            "arrears_letter_1_date": options.fetch(:arrears_letter_1_date, '')
          }]
        end
      end
    end
  end
end
