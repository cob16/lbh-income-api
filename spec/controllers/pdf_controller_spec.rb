require 'rails_helper'

describe PdfController, type: :controller do
  let(:template_path) { 'path/to/temp' }
  let(:template_id) { 'letter_1_template' }
  let(:template_name) { 'Letter 1 template' }
  let(:found_payment_ref) { Faker::Number.number(4) }
  let(:not_found_payment_ref) { 123 }
  let(:preview_html) { "<p>#{Faker::HitchhikersGuideToTheGalaxy.quote}</p>" }

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

  it 'generates pdf preview with template details and case' do
    expect_any_instance_of(Hackney::PDF::PreviewGenerator).to receive(:execute).and_return(preview_html)

    post :send_letter, params: { payment_ref: found_payment_ref, template_id: template_id }

    response_json = JSON.parse(response.body)

    expect(response_json['case']['payment_ref']).to eq(found_payment_ref)
    expect(response_json['template']['id']).to eq(template_id)
    expect(response_json['preview']).to eq(preview_html)
  end

  context 'when payment_ref is not found' do
    it 'returns 404' do
      post :send_letter, params: { payment_ref: not_found_payment_ref, template_id: template_id }

      expect(response.status).to eq(404)
    end
  end
end
