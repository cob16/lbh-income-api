require 'rails_helper'

describe Hackney::Income::Jobs::SendLetterToGovNotifyJob do
  let(:document_id) { Hackney::Cloud::Document.create(filename: 'test_file.txt', uuid: SecureRandom.uuid).id }

  after { described_class.perform_now(document_id: document_id) }

  it { expect_any_instance_of(Hackney::Notification::SendManualPrecompiledLetter).to receive(:execute).once }

  it { expect_any_instance_of(Hackney::Notification::GovNotifyGateway).to receive(:send_precompiled_letter).once }
end
