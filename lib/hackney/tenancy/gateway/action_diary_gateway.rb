require 'httparty'
require "#{Rails.root}/lib/hackney/tenancy/exceptions/tenancy_api_exception"

module Hackney
  module Tenancy
    module Gateway
      class ActionDiaryGateway
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

        def create_entry(tenancy_ref:, action_code:, action_balance:, comment:, username: nil)
          body = {
            tenancyAgreementRef: tenancy_ref,
            actionCode: action_code,
            actionBalance: action_balance,
            comment: comment
            # "companyCode": 'string',
          }
          body[:username] = username unless username.nil?

          responce = self.class.post('/api/v2/tenancies/arrears-action-diary', @options.merge(body: body.to_json))
          raise Hackney::Tenancy::Exceptions::TenancyApiException, responce unless responce.success?
          responce
        end
      end
    end
  end
end
