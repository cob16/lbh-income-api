class DocumentsController < ApplicationController
  def download
    doc_download = letter_use_case_factory.download.execute(id: params.fetch(:id))
    doc = doc_download[:document]

    tenancy_ref = get_tenancy_ref(doc)
    if params[:username] != ''
      income_use_case_factory.add_action_diary.execute(
        tenancy_ref: tenancy_ref,
        action_code: 'SLB',
        comment: 'LBA sent (SC)',
        username: params[:username]
      )
    end
    send_file doc_download[:filepath], type: doc.mime_type, filename: letter_file_name(doc)
  end

  # def mark_downloaded
  #   document = Hackney::Cloud::Document.find(params.fetch(:id))
  #   if document.status != 'downloaded'
  #     document.update(status:'downloaded')
  #   end
  #   head :ok
  # end

  def index
    render json: letter_use_case_factory.get_all_documents.execute(payment_ref: params.fetch(:payment_ref, nil))
  end

  private

  def letter_file_name(doc)
    return 'letter.pdf' unless doc.metadata
    meta = JSON.parse(doc.metadata).symbolize_keys
    pay_ref = meta.dig(:payment_ref)
    letter_template = meta.dig(:template_id)
    pay_ref.to_s + '_' + letter_template.to_s + doc.extension
  end

  def get_tenancy_ref(doc)
    tenancy_finder = Hackney::Income::UniversalHousingLeaseholdGateway.new
    payment_ref = JSON.parse(doc.metadata)['payment_ref']
    result = tenancy_finder.get_tenancy_ref(payment_ref: payment_ref)
    result[:tenancy_ref]
  end
end
