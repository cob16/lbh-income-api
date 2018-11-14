class StubGovNotifyGateway
  extend MessagesHelper
  EXAMPLE_TEMPLATES = example_templates

  def initialize(sms_sender_id:, api_key:); end

  def send_text_message(phone_number:, template_id:, reference:, variables:); end

  def send_email(recipient:, template_id:, reference:, variables:); end

  def get_templates(type:)
    EXAMPLE_TEMPLATES
  end
end
