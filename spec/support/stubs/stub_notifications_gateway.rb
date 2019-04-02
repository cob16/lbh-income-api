module Hackney
  module Income
    class StubNotificationsGateway
      DEFAULT_TEMPLATES = [
        { id: '00001', name: 'Quick Template', body: 'quick ((first name))!', subject: nil },
        { id: '00002', name: 'Where Are You?', body: 'where are you from ((title)) ((last name))??', subject: nil },
        { id: '00003', name: 'Email', body: 'Sending emails is cool and fun', subject: 'Hi ((name))!' },
        { id: '00004', name: 'A Quicker Template', body: "a body\n should be here?", subject: nil }
      ].freeze

      private_constant :DEFAULT_TEMPLATES
      attr_reader :last_text_message, :last_email, :last_precompiled_letter

      def initialize(templates: DEFAULT_TEMPLATES, sms_sender_id: nil, api_key: nil, last_text_message: nil, last_precompiled_letter: nil)
        @templates = templates
        @last_text_message = nil
        @last_email = nil
        @last_precompiled_letter = nil
      end

      def get_template_name(id)
        get_template(id)&.fetch(:name, nil)
      end

      def get_text_templates
        @templates
      end

      def get_email_templates
        @templates
      end

      def send_text_message(phone_number:, template_id:, reference:, variables:)
        @last_text_message = {
          phone_number: phone_number,
          template_id: template_id,
          reference: reference,
          variables: variables
        }
        body = get_template(template_id)&.fetch(:body, nil)
        Hackney::Notification::Domain::NotificationReceipt.new(body: body)
      end

      def send_email(recipient:, template_id:, reference:, variables:)
        @last_email = {
          recipient: recipient,
          template_id: template_id,
          reference: reference,
          variables: variables
        }
        body = get_template(template_id)&.fetch(:body, nil)
        Hackney::Notification::Domain::NotificationReceipt.new(body: body)
      end

      def send_precompiled_letter(unique_reference:, letter_pdf:)
        postage = 'second'
        body = "#{unique_reference} sent via #{postage} postage"
        Hackney::Notification::Domain::NotificationReceipt.new(body: body)
      end

      def precompiled_letter_state(unique_reference:)
        { status: StubNotification.new(reference:unique_reference, id: SecureRandom.uuid).status }
      end

      private

      def get_template(id)
        @templates.find { |template| template[:id] == id }
      end
    end
  end
end

#<Notifications::Client::Notification:0x000055faabc8b008
class StubNotification
  attr_reader :status
  def initialize(reference:, id:)
    @body="",
    @completed_at=Time.now,
    @created_at=Time.now,
    @created_by_name=nil,
    @email_address=nil,
    @id=id,
    @line_1=reference,
    @line_2=nil,
    @line_3=nil,
    @line_4=nil,
    @line_5=nil,
    @line_6=nil,
    @phone_number=nil,
    @postage="second",
    @postcode=nil,
    @reference=reference,
    @sent_at=nil,
    @status="received",
    @subject="Pre-compiled PDF",
    @template=
    {"id"=>reference,
     "uri"=>
      "https://api.notifications.service.gov.uk/v2/template/49b6d27b-ebea-4f5a-94e9-12aff73395df/version/1",
     "version"=>1},
    @type="letter"
  end
end
