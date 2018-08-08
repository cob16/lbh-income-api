module UniversalHousingHelper
  def create_uh_tenancy_agreement(tenancy_ref:, current_balance:)
    Hackney::UniversalHousing::Client.connection[:tenagree].insert(tag_ref: tenancy_ref, cur_bal: current_balance)
  end

  def create_uh_transaction(tenancy_ref:, amount: 0.0, date: Date.today, type: '')
    Hackney::UniversalHousing::Client.connection[:rtrans].insert(tag_ref: tenancy_ref, real_value: amount, post_date: date, trans_type: type, batchid: rand(1..100000))
  end

  def create_uh_arrears_agreement(tenancy_ref:, status:)
    Hackney::UniversalHousing::Client.connection[:arag].insert(arag_ref: Faker::IDNumber.valid, tag_ref: tenancy_ref, arag_status: status)
  end

  def create_uh_action(tenancy_ref:, code:, date:)
    Hackney::UniversalHousing::Client.connection[:araction].insert(tag_ref: tenancy_ref, action_code: code, action_date: date)
  end

  def truncate_uh_tables
    Hackney::UniversalHousing::Client.connection[:tenagree].truncate
    Hackney::UniversalHousing::Client.connection[:rtrans].truncate
    Hackney::UniversalHousing::Client.connection[:arag].truncate
    Hackney::UniversalHousing::Client.connection[:araction].truncate
  end
end
