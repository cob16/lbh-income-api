require 'rails_helper'

describe PdfController, type: :controller do
  let(:template_path) { 'path/to/temp' }
  let(:template_name) { 'test_template' }

  it 'gets letter templates' do
    expect_any_instance_of(Hackney::PDF::GetTemplates).to receive(:execute).and_return(
      path: template_path,
      name: template_name
    )

    get :get_templates

    expect(response.body).to eq(
      {
        path: template_path,
        name: template_name
      }.to_json
    )
  end
end
