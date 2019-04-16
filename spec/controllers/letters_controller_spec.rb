require 'rails_helper'

describe LettersController, type: :controller do
  let(:template_path) { 'path/to/temp' }
  let(:template_id) { 'letter_1_template' }
  let(:template_name) { 'Letter 1 template' }
  let(:preview_html) { "<p>#{Faker::HitchhikersGuideToTheGalaxy.quote}</p>" }

  class StubGetTemplates
    def initialize(template_directory_path:) end

    def execute
      {
        path: 'path/to/temp',
        id: 'letter_1_template',
        name: 'Letter 1 template'
      }
    end
  end

  class StubHackneyPdfPreview
    def initialize(get_templates_gateway:, leasehold_information_gateway:) end

    def execute(payment_ref:, template_id:)
      {
        case: 'leasehold_info',
        template: 'template',
        uuid: 'uuid',
        preview: 'preview_with_errors[:html],',
        errors: 'preview_with_errors[:errors]'
      }
    end
  end

  describe '#get_templates' do
    it 'gets letter templates' do
      expect_any_instance_of(Hackney::PDF::GetTemplates).to receive(:execute).and_return({})

      get :get_templates

      expect(response.status).to eq(200)
    end
  end

  describe '#send_letter' do
    context 'when user "accepts" the preview' do
      let(:user_id) { Faker::Number.number }
      let(:uuid) { SecureRandom.uuid }

      before do
        Rails.cache.write(uuid, preview: preview_html, case: { payment_ref: 123 })
      end

      it 'calls succefully' do
        post :send_letter, params: { uuid: uuid, user_id: user_id }

        expect(response).to be_successful
      end

      it 'calls the usecase' do
        expect_any_instance_of(Hackney::Income::ProcessLetter)
          .to receive(:execute).with(uuid: uuid, user_id: user_id)

        post :send_letter, params: { uuid: uuid, user_id: user_id }
      end
    end
  end

  describe '#create' do
    context 'when all data is is found' do
      let(:found_payment_ref) { Faker::Number.number(4) }
      let(:preview_uuid) { SecureRandom.uuid }

      it 'generates pdf(html) preview with template details, case and empty errors' do
        expect_any_instance_of(Hackney::PDF::Preview).to receive(:execute).and_return({})

        post :create, params: { payment_ref: found_payment_ref, template_id: template_id }

        expect(response.status).to eq 200
      end
    end

    context 'when payment_ref is not found' do
      let(:not_found_payment_ref) { 123 }

      it 'returns 404' do
        expect_any_instance_of(Hackney::PDF::Preview)
          .to receive(:execute)
          .and_raise(ArgumentError.new('payment_ref does not exist!'))

        post :create, params: { payment_ref: not_found_payment_ref, template_id: template_id }

        expect(response.status).to eq(404)
      end
    end
  end
end
