require 'rails_helper'

describe Hackney::Tenancy::Gateway::ActionDiaryGateway do
  let(:host) { Faker::Internet.url('example.com') }
  let(:key) { SecureRandom.uuid }
  let(:tenancy_ref) { Faker::Lorem.characters(8) }
  let(:username) { Faker::Name.name }
  let(:action_code) { Faker::Internet.slug }
  let(:comment) { Faker::Lorem.paragraph }

  let(:required_headers) do
    {
      'X-Api-Key' => key,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  end

  subject { described_class.new(host: host, api_key: key) }

  context 'when creating an action diary entry' do
    before do
      stub_request(:post, /#{host}/).with(headers: required_headers).to_return(status: 200)
    end

    it 'should create an system entry' do
      subject.create_entry(
        tenancy_ref: tenancy_ref,
        action_code: action_code,
        comment: comment
      )

      assert_requested(
        :post, host + '/api/v2/tenancies/arrears-action-diary',
        headers: required_headers,
        body: {
          tenancyAgreementRef: tenancy_ref,
          actionCode: action_code,
          comment: comment
        }.to_json,
        times: 1
      )
    end

    it 'should create a entry with user user if username supplied' do
      subject.create_entry(tenancy_ref: tenancy_ref,
                           action_code: action_code,
                           comment: comment,
                           username: username)

      assert_requested(
        :post, host + '/api/v2/tenancies/arrears-action-diary',
        headers: required_headers,
        body: {
          tenancyAgreementRef: tenancy_ref,
          actionCode: action_code,
          comment: comment,
          username: username
        }.to_json,
        times: 1
      )
    end
  end

  context 'when tenancy api returns an error' do
    before do
      stub_request(:post, /#{host}/).with(headers: required_headers).to_return(status: 500)
    end

    it 'an exception should be thrown' do
      expect {
        subject.create_entry(
          tenancy_ref: tenancy_ref,
          action_code: action_code,
          comment: comment,
          username: username
        )
      }.to raise_error(Hackney::Tenancy::Exceptions::TenancyApiException, "[Tenancy API error: Received 500 response] when trying to create action diary entry for #{tenancy_ref}")
    end
  end
end
