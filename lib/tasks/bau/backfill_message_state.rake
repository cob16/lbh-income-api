namespace :bau do
  desc 'backfill message state'
  task :backfill_message_state, [:document_uuid] do |_task, args|
    backfill_message_state(
      document_uuid: args.fetch(:document_uuid)
    )
  end
end

def backfill_message_state(document_uuid:)
  use_cases = Hackney::Income::UseCaseFactory.new

  document = Hackney::Cloud::Document.find_by!(uuid: document_uuid)
  date = document.created_at

  metadata = JSON.parse(document.metadata).symbolize_keys
  payment_ref = metadata.dig(:payment_ref)
  tenancy_ref = Hackney::Income::UniversalHousingLeaseholdGateway.new.get_tenancy_ref(payment_ref: payment_ref).dig(:tenancy_ref)

  if document.status == 'received'
    puts 'already done'
    return false
  else
    puts "i will mark document #{document.uuid} as received"
    puts "i send an action diary event to tenancy_ref: #{tenancy_ref}, dated on '#{date.iso8601}' "

    use_cases.add_action_diary.execute(
      user_id: nil,
      date: date,
      tenancy_ref: tenancy_ref,
      action_code: 'LL2',
      comment: "Letter '#{document.uuid}' from 'letter_2_in_arrears_LH' \
      letter was sent access it by visiting documents?payment_ref=#{payment_ref}. \
      Please note the action diary balance for this entry is incorrect (the \
      correct amount will be stated in the letter)."
    )

    document.status = 'received'
    document.save!
    puts 'done!'
  end
end
