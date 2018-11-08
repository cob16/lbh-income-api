class MessagesController < ApplicationController
  def send_sms
    income_use_case_factory.send_sms.execute(
      tenancy_ref: 'what?',
      template_id: params.fetch(:template_id),
      phone_number: params.fetch(:phone_number),
      reference: params.fetch(:reference),
      variables: JSON.parse(params.fetch(:personalisation))
    )
  end

end
