require "#{Rails.root}/lib/hackney/service_charge/exceptions/service_charge_exception"

class LettersController < ApplicationController
  def get_templates
    render json: pdf_use_case_factory.get_templates.execute
  end

  def create
    render json: pdf_use_case_factory.get_preview.execute(
      payment_ref: params.fetch(:payment_ref),
      template_id: params.fetch(:template_id)
    )
  rescue Hackney::ServiceCharge::Exceptions::ServiceChargeException
    head(404)
  end

  def send_letter

  end
end


__END__
FIXME: REMOVE
document_uuid = params.fetch(:document_uuid)
letter_document = DocumentCache.find_by(uuid: document_uuid)

s = Hackney::Notification::SendManualPrecompiledLetter.new(
  user_id: params.fetch(:user_id, nil), payment_ref: params.fetch(:payment_ref),
  unique_reference: document_uuid, letter_pdf: letter_pdf
)

s.execute
