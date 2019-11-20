require 'rails_helper'

describe DocumentsController do
  describe '#index' do
    it 'returns all documents' do
      expect_any_instance_of(Hackney::Letter::AllDocumentsUseCase)
        .to receive(:execute)

      get :index
    end

    context 'when the payment_ref param is present' do
      let(:payment_ref) { Faker::Number.number(10) }

      it 'returns all documents filtered by payment_ref' do
        expect_any_instance_of(Hackney::Letter::AllDocumentsUseCase)
          .to receive(:execute).with(payment_ref: payment_ref)

        get :index, params: { payment_ref: payment_ref }
      end
    end
  end
end
