require 'rails_helper'

describe UseCases::CreateDocumentModel do
  subject { described_class.new(spy_gateway) }

  let(:spy_gateway) { spy }

  context 'saves the document model' do

    it 'passes the correct information to the gateway' do
      subject.execute()

    expect(spy_gateway).to have_received(:create).with()
    end
  end
end
