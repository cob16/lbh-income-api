require 'rails_helper'

describe Hackney::Income::Jobs::SendIncomeCollectionLetterToGovNotifyJob do
  let(:document) { create(:document, filename: 'test.txt', ext_message_id: nil) }
  let(:document_id) { document.id }

  let(:message_receipt) { Hackney::Notification::Domain::NotificationReceipt.new(body: 'body', message_id: SecureRandom.uuid) }

  before {
    expect_any_instance_of(Aws::S3::Encryption::Client).to receive(:get_object).and_return(AwsClientResponse.new)
    expect_any_instance_of(Hackney::Notification::SendPrecompiledLetter).to receive(:execute).with(
      unique_reference: document.uuid, letter_pdf: instance_of(Tempfile)
    ).and_return(message_receipt)
  }

  it 'updates with message id' do
    doc = Hackney::Cloud::Document.find(document_id)
    expect { described_class.perform_now(document_id: document_id) }.to change { doc.reload.ext_message_id }.from(nil).to(message_receipt.message_id)
  end
end
