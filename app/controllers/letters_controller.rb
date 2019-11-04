require "#{Rails.root}/lib/hackney/service_charge/exceptions/service_charge_exception"

class LettersController < ApplicationController
  def get_templates
    render json: pdf_use_case_factory.get_templates.execute
  end

  def create
    letter_data = UseCases::ViewLetter.new.execute
    _uuid = UseCases::SaveToCache.new(cache: Rails.cache).execute(data: letter_data)

    json = pdf_use_case_factory.get_preview.execute(
      payment_ref: params.fetch(:payment_ref),
      template_id: params.fetch(:template_id)
    )

    render json: json
  rescue Hackney::Income::TenancyNotFoundError
    head(404)
  end

  def send_letter
    pop_letter_from_cache = UseCases::PopLetterFromCache.new(cache: Rails.cache)
    letter = pop_letter_from_cache.execute(uuid: params.fetch(:uuid))

    generate_pdf = UseCases::GeneratePdf.new
    pdf = generate_pdf.execute(uuid: params.fetch(:uuid), letter_html: letter[:preview])

    create_document_model = UseCases::CreateDocumentModel.new(Hackney::Cloud::Document)
    document_model = create_document_model.execute(letter_html: letter[:preview], uuid: params.fetch(:uuid), filename: params.fetch(:uuid), metadata: {
      user_id: params.fetch(:user_id),
      payment_ref: letter[:case][:payment_ref],
      template: letter[:template]
    })

    save_letter = UseCases::SaveLetterToCloud.new(Rails.configuration.cloud_adapter)
    document_data = save_letter.execute(
      uuid: params.fetch(:uuid),
      bucket_name: Rails.application.config_for('cloud_storage')['bucket_docs'],
      pdf: pdf
    )

    update_document_s3_url = UseCases::UpdateDocumentS3Url.new
    update_document_s3_url.execute(document_model: document_model, document_data: document_data)

    Hackney::Income::Jobs::SendLetterToGovNotifyJob.perform_later(document_id: document_model.id)
  end
end
