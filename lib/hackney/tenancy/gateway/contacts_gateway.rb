require 'httparty'
require "#{Rails.root}/lib/hackney/tenancy/exceptions/tenancy_api_exception"

module Hackney
  module Tenancy
    module Gateway
      class ContactsGateway
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

        def get_responsible_contacts(tenancy_ref:)
          response = self.class.get("/api/v1/tenancies/#{URI.encode_www_form_component(tenancy_ref)}/contacts", @options)
          raise Hackney::Tenancy::Exceptions::TenancyApiException, response unless response.success?
          json_to_domain_contact_array(response.body)
        end

        def json_to_domain_contact_array(json_string, responsible_only: true)
          json = JSON.parse(json_string, symbolize_names: true)
          contacts_json = json.dig(:data, :contacts)
          return [] if contacts_json.nil? || contacts_json.empty?

          contacts_json = contacts_json.select { |contact| contact[:responsible] } if responsible_only

          contacts_json.each_with_object([]) do |contact, contacts_list|
            phone_numbers = []
            phone_numbers << contact[:telephone1] if contact[:telephone1]
            phone_numbers << contact[:telephone2] if contact[:telephone2]
            phone_numbers << contact[:telephone3] if contact[:telephone3]

            contacts_list << Hackney::Income::Domain::Contact.new.tap do |c|
              c.phone_numbers = phone_numbers
              c.email = contact[:email]
            end
          end
        end
      end
    end
  end
end
