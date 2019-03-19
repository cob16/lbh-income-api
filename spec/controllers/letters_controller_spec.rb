require 'rails_helper'

describe LettersController, type: :controller do
  let(:template_path) { 'path/to/temp' }
  let(:template_id) { 'letter_1_template' }
  let(:template_name) { 'Letter 1 template' }
  let(:preview_html) { "<p>#{Faker::HitchhikersGuideToTheGalaxy.quote}</p>" }

  describe '#get_templates' do
    it 'gets letter templates' do
      expect_any_instance_of(Hackney::PDF::GetTemplates).to receive(:execute).and_return(
        path: template_path,
        id: template_id,
        name: template_name
      )

      get :get_templates

      expect(response.body).to eq(
        {
          path: template_path,
          id: template_id,
          name: template_name
        }.to_json
      )
    end
  end

  describe '#send_letter' do
    # before { post :send_letter, params: { uuid: uuid, user_id: user_id } }

    context 'user "accepts" the preview' do
      let(:user_id) { Faker::Number.number }
      let(:uuid) { SecureRandom.uuid }

      xit 'calls succefully' do
        post :send_letter, params: { uuid: uuid, user_id: user_id }

        expect(response).to be_successful
      end

      it 'calls the usecase' do
        expect_any_instance_of(Hackney::Income::ProcessLetter)
          .to receive(:execute).with(uuid: uuid, user_id: user_id)

        post :send_letter, params: { uuid: uuid, user_id: user_id }
      end

      # TODO: expect to send
      # expect_any_instance_of(Hackney::Notification::SendManualPrecompiledLetter).to receive(:execute)
    end
  end

  describe '#create' do
    context 'when all data is is found' do
      let(:found_payment_ref) { Faker::Number.number(4) }
      let(:preview_uuid) { SecureRandom.uuid }

      it 'generates pdf(html) preview with template details, case and empty errors' do
        expect_any_instance_of(Hackney::PDF::PreviewGenerator).to receive(:execute).and_return(html: preview_html, errors: [])

        post :create, params: { payment_ref: found_payment_ref, template_id: template_id }

        response_json = JSON.parse(response.body)

        expect(response_json['case']['payment_ref']).to eq(found_payment_ref)
        expect(response_json['template']['id']).to eq(template_id)
        expect(response_json['preview']).to eq(preview_html)
        expect(response_json['uuid']).not_to be_nil
        expect(response_json['errors']).to eq([])

        expect(Rails.cache.read(response_json['uuid'])).to eq(preview_html)
      end
    end

    context 'when some data is missing' do
      let(:missing_optional_data) { 111 }
      let(:missing_mandatory_data) { 222 }

      it 'no errors when only optional data is missing' do
        post :create, params: { payment_ref: missing_optional_data, template_id: template_id }

        response_json = JSON.parse(response.body)

        expect(response_json['errors']).to eq([])
      end

      it 'returns errors when mandatory data is missing' do
        post :create, params: { payment_ref: missing_mandatory_data, template_id: template_id }

        response_json = JSON.parse(response.body)

        expect(response_json['errors']).to eq([{
          'name' => 'correspondence_address_1',
          'message' => 'missing mandatory field'
        }])
      end
    end

    context 'when payment_ref is not found' do
      let(:not_found_payment_ref) { 123 }

      it 'returns 404' do
        post :create, params: { payment_ref: not_found_payment_ref, template_id: template_id }

        expect(response.status).to eq(404)
      end
    end
  end
end
