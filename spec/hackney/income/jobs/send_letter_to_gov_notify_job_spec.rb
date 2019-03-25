require 'rails_helper'

describe Hackney::Income::Jobs::SendLetterToGovNotifyJob do
  let(:document_id) do
    Hackney::Cloud::Document.create(
      filename: 'test_file.txt',
      uuid: SecureRandom.uuid,
      metadata: {
        user_id: 123,
        payment_ref: 1_234_567_890
      }.to_json
    ).id
  end

  after { described_class.perform_now(document_id: document_id) }

  it do
    expect_any_instance_of(Aws::S3::Encryption::Client).to receive(:get_object).and_return(AwsResponse.new)

    expect_any_instance_of(Hackney::Notification::SendManualPrecompiledLetter).to receive(:execute).once
    # expect_any_instance_of(Hackney::Notification::GovNotifyGateway).to receive(:send_precompiled_letter).once
  end
end

class AwsResponse
  def key; end

  def body
    StringIO.new
  end
end
