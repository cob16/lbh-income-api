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

        def create_entry(tenancy_ref:, action_code:, comment:, username: nil)
          body = {
            tenancyAgreementRef: tenancy_ref,
            actionCode: action_code,
            actionCategory: '', # required by the API, but never set by us
            comment: comment
          }
          body[:username] = username unless username.nil?

          responce = self.class.post('/api/v2/tenancies/arrears-action-diary', @options.merge(body: body.to_json))

          unless responce.success?
            raise Hackney::Tenancy::Exceptions::TenancyApiException.new(responce),
                  "when trying to create action diary entry for #{tenancy_ref}"
          end

          responce
        end
      end
    end
  end
end
