require 'rails_helper'

describe DocumentsController do
  describe '#download' do
    let(:template_id) { Faker::Demographic.demonym }
    let(:payment_ref) { Faker::Number.number(10) }

    let(:metadata) { { template_id: template_id, payment_ref: payment_ref }.to_json }
    let(:document) { create(:document, metadata: metadata) }
    let(:filename) { payment_ref + '_' + template_id + document.extension }

    let(:download_use_case) { Hackney::Letter::DownloadUseCase }
    let(:add_action_diary_use_case) { Hackney::Tenancy::AddActionDiaryEntry }

    let(:prop_ref) { Faker::Number.number(6) }
    let(:postcode) { Faker::Address.postcode }
    let(:email) { Faker::Internet.email }
    let(:tenancy_ref) { Faker::Number.number(6) }
    let(:house_ref) { Faker::Number.number(6) }
    let(:real_template_id) { 'letter_before_action' }
    let(:username) { Faker::Name.name }

    context 'when the document is present' do
      before do
        create_valid_uh_records_for_a_letter
        expect_any_instance_of(download_use_case)
          .to receive(:execute).with(id: document.id.to_s)
                               .and_return(filepath: Tempfile.new.path, document: document)
        expect_any_instance_of(add_action_diary_use_case)
          .to receive(:execute).with(
            tenancy_ref: tenancy_ref,
            action_code: 'SLB',
            comment: 'LBA sent (SC)',
            username: username
          ).and_return(header: 200)
        get :download, params: { id: document.id, username: username }
      end

      it { expect(response).to be_successful }
      it { expect(response.header['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"") }
      it { expect(response.content_type).to eq document.mime_type }
    end
  end

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

  def create_valid_uh_records_for_a_letter
    create_uh_property(
      property_ref: prop_ref,
      post_code: postcode
    )
    create_uh_tenancy_agreement(
      prop_ref: prop_ref,
      tenancy_ref: tenancy_ref,
      u_saff_rentacc: payment_ref,
      house_ref: house_ref
    )
    create_uh_househ(
      house_ref: house_ref,
      prop_ref: prop_ref,
      corr_preamble: 'address1',
      corr_desig: 'address2',
      corr_postcode: postcode,
      house_desc: 'Test Name'
    )
    create_uh_rent(
      prop_ref: prop_ref,
      sc_leasedate: ''
    )
    create_uh_postcode(
      post_code: postcode,
      aline1: ''
    )
  end
end
