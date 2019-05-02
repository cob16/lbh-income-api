FactoryBot.define do
  factory :document, class: Hackney::Cloud::Document do
    uuid { SecureRandom.uuid }
    mime_type { 'application/pdf' }
    extension { '.pdf' }
    metadata { '{"user_id":115,"payment_ref":"4923003502","template":{"name":"Letter 1 in arrears fh","id":"letter_1_in_arrears_FH"}}' }
    ext_message_id { SecureRandom.uuid }
    status { 'uploaded' }
  end
end
