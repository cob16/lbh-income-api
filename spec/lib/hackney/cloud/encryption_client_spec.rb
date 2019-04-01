require 'rails_helper'
require './lib/hackney/cloud/encryption_client'

describe Hackney::Cloud::EncryptionClient do
  let(:kms_double) { double }

  it 'returns a new Encryption client' do
    allow(Aws::KMS::Client).to receive(:new).and_return(kms_double)

    described_class.new('123').create
  end
end
