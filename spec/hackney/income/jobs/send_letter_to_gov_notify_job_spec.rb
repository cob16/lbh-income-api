require 'rails_helper'

describe Hackney::Income::Jobs::SendLetterToGovNotifyJob do
  let(:document_id) do Hackney::Cloud::Document.create(
    filename: 'test_file.txt',
    uuid: SecureRandom.uuid,
    metadata: {
      user_id: 123,
      payment_ref: 1234567890
    }.to_json
  ).id
  end

  after { described_class.perform_now(document_id: document_id) }

  # it do
  # end

  it do
    expect_any_instance_of(Hackney::Cloud::Adapter::Fake).to receive(:download).and_return('thing')
    expect_any_instance_of(Hackney::Notification::SendManualPrecompiledLetter).to receive(:execute).once
    expect_any_instance_of(Hackney::Notification::GovNotifyGateway).to receive(:send_precompiled_letter).once
  end


end

# subject(:s3) { described_class.new(encryption_client_double) }
#
# let(:encryption_client_double) { double }
#
# it 'downloads a file from S3' do
#   expect(encryption_client_double).to receive(:get_object).with(
#     bucket: 'my-bucket',
#     key: filename
#   )
#   s3.download('my-bucket', filename)
# end
