require 'uk_postcode'
require_relative 'service_charge_adapter'
require "#{Rails.root}/lib/hackney/service_charge/exceptions/service_charge_exception"
require "#{Rails.root}/spec/support/case_helper"

module Hackney
  module ServiceCharge
    module Gateway
      class ServiceChargeGateway
        include CaseHelper

        NON_EXISTING_REF = '123'.freeze
        MISSING_OPTIONAL_DATA_REF = '111'.freeze
        MISSING_MANDATORY_DATA_REF = '222'.freeze

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
          # This is here to emulate what happens when a payment ref is not found,
          # this will disappear when we have an actual api endpoint to call
          raise Hackney::ServiceCharge::Exceptions::ServiceChargeException, refs if refs.include?(NON_EXISTING_REF)

          return [] if refs.empty?
          refs.map do |ref|
            sc_case = example_case(get_stub_options(ref))
            {
              tenancy_ref: sc_case.fetch(:tenancy_ref),
              correspondence_address_1: sc_case.fetch(:correspondence_address_1),
              correspondence_address_2: sc_case.fetch(:correspondence_address_2),
              correspondence_address_3: sc_case.fetch(:correspondence_address_3),
              correspondence_postcode: sc_case.fetch(:correspondence_postcode),
              property_address: sc_case.fetch(:property_address),
              payment_ref: sc_case.fetch(:payment_ref),
              balance: sc_case.fetch(:balance),
              total_collectable_arrears_balance: sc_case.fetch(:collectable_arrears_balance),
              lba_expiry_date: sc_case.fetch(:lba_expiry_date),
              original_lease_date: sc_case.fetch(:original_lease_date),
              date_of_current_purchase_assignment: sc_case.fetch(:date_of_current_purchase_assignment),
              original_Leaseholders: sc_case.fetch(:original_Leaseholders),
              previous_letter_sent: sc_case.fetch(:previous_letter_sent),
              arrears_letter_1_date: sc_case.fetch(:arrears_letter_1_date),
              international: international?(sc_case.fetch(:correspondence_postcode)),
              lessee_full_name: get_lessee_name(name_array: sc_case.fetch(:full_names_of_current_lessees)),
              lessee_short_name: get_lessee_name(name_array: sc_case.fetch(:full_names_of_current_lessees), length: :short)
            }
          end
        end

        private

        def international?(postcode)
          !UKPostcode.parse(postcode).valid?
        end

        def get_lessee_name(name_array:, length: :full)
          return name_array.first.split(' ').first if length == :short
          name_array.first
        end

        def get_stub_options(ref)
          return { payment_ref: ref, correspondence_address_3: '' } if ref == MISSING_OPTIONAL_DATA_REF
          return { payment_ref: ref, correspondence_address_1: '' } if ref == MISSING_MANDATORY_DATA_REF
          { payment_ref: ref }
        end
      end
    end
  end
end
