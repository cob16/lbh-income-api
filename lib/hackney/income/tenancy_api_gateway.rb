module Hackney
  module Income
    class TenancyApiGateway
      def initialize(host:, key:)
        @host = host
      end

      def get_tenancies_by_refs(refs)
        return [] if refs.empty?

        response = RestClient.get(
          "#{@host}/tenancies",
          'x-api-key' => @key,
          params: { tenancy_refs: convert_to_params_array(refs) }
        )
        body = JSON.load(response.body)

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

      def convert_to_params_array(refs)
        RestClient::ParamsArray.new(refs.map.with_index(0) { |e, i| [i.to_s, e] }.to_a)
      end
    end
  end
end
