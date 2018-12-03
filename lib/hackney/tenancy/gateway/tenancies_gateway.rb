require 'uri'
require 'net/http'
require "#{Rails.root}/lib/hackney/tenancy/exceptions/tenancy_api_exception"

module Hackney
  module Tenancy
    module Gateway
      class TenanciesGateway
        def initialize(host:, key:)
          @host = host
          @key = key
        end

        def get_tenancies_by_refs(refs)
          return [] if refs.empty?

          uri = URI("#{@host}/api/v1/tenancies?#{params_list('tenancy_refs', refs)}")

          req = Net::HTTP::Get.new(uri)
          req['X-Api-Key'] = @key

          res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

          raise Hackney::Tenancy::Exceptions::TenancyApiException unless res.is_a? Net::HTTPSuccess

          body = JSON.parse(res.body)

          body['tenancies'].map do |tenancy|
            action_missing = tenancy.dig('latest_action', 'code').nil?
            contact_missing = tenancy.dig('primary_contact', 'name').nil?

            {
              ref: tenancy.fetch('ref'),
              current_balance: tenancy.fetch('current_balance'),
              current_arrears_agreement_status: tenancy.fetch('current_arrears_agreement_status'),
              latest_action: action_missing ? nil : {
                code: tenancy.dig('latest_action', 'code'),
                date: Time.parse(tenancy.dig('latest_action', 'date'))
              },
              primary_contact: contact_missing ? nil : {
                name: tenancy.dig('primary_contact', 'name'),
                short_address: tenancy.dig('primary_contact', 'short_address'),
                postcode: tenancy.dig('primary_contact', 'postcode')
              }
            }
          end
        end

        private

        def params_list(key, values)
          values.each_with_index.map do |value, index|
            "#{key}[#{index}]=#{value}"
          end.join('&')
        end
      end
    end
  end
end
