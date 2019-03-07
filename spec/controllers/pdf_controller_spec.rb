require 'rails_helper'

describe PdfController, type: :controller do
  let(:template_path) { 'path/to/temp' }
  let(:template_id) { 'letter_1_template' }
  let(:template_name) { 'Letter 1 template' }
  let(:found_payment_ref) { Faker::Number.number(4) }
  let(:missing_optional_data) { 111 }
  let(:missing_mandatory_data) { 222 }
  let(:not_found_payment_ref) { 123 }
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
    context 'when all data is is found' do
      it 'generates pdf preview with template details, case and empty errors' do
        expect_any_instance_of(Hackney::PDF::PreviewGenerator).to receive(:execute).and_return(preview_html)

        post :send_letter, params: { payment_ref: found_payment_ref, template_id: template_id }

        response_json = JSON.parse(response.body)

        expect(response_json['case']['payment_ref']).to eq(found_payment_ref)
        expect(response_json['template']['id']).to eq(template_id)
        expect(response_json['preview']).to eq(preview_html)
        expect(response_json['errors']).to eq([])
      end
    end

    context 'when some data is missing' do
      it 'no errors when only optional data is missing' do
        post :send_letter, params: { payment_ref: missing_optional_data, template_id: template_id }

        response_json = JSON.parse(response.body)

        expect(response_json['errors']).to eq([])
      end

      it 'returns errors when mandatory data is missing' do
        post :send_letter, params: { payment_ref: missing_mandatory_data, template_id: template_id }

        response_json = JSON.parse(response.body)

        expect(response_json['errors']).to eq([{
          field: 'correspondence_address_one',
          error: 'missing mandatory field'
        }])
      end
    end

    context 'when payment_ref is not found' do
      it 'returns 404' do
        post :send_letter, params: { payment_ref: not_found_payment_ref, template_id: template_id }

        expect(response.status).to eq(404)
      end
    end
  end
end
