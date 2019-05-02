FactoryBot.define do
  factory :document, class: Hackney::Cloud::Document do
    uuid { SecureRandom.uuid }
    mime_type { 'application/pdf' }
    extension { '.pdf' }
    metadata { '{"user_id":115,"payment_ref":"1940972804","name":"Letter 1 template","id":"letter_1_template"}' }
    ext_message_id { SecureRandom.uuid }
    status { 'uploaded' }
  end
end
