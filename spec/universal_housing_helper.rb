module UniversalHousingHelper
  def create_uh_tenancy_agreement(tenancy_ref:, current_balance:)
    universal_housing_client.execute("INSERT [dbo].[tenagree] (tag_ref, cur_bal) VALUES ('#{tenancy_ref}', #{current_balance})").do
  end

  def create_uh_transaction(tenancy_ref:, amount: 0.0, date: Date.today, type: '')
    universal_housing_client.execute("INSERT [dbo].[rtrans] (tag_ref, real_value, post_date, trans_type, batchid) VALUES ('#{tenancy_ref}', '#{amount}', '#{date}', '#{type}', #{rand(1..100000)})").do
  end

  def create_uh_arrears_agreement(tenancy_ref:, status:)
    universal_housing_client.execute("INSERT [dbo].[arag] (arag_ref, tag_ref, arag_status) VALUES ('#{Faker::IDNumber.valid}', '#{tenancy_ref}', '#{status}')").do
  end

  def create_uh_action(tenancy_ref:, code:, date:)
    universal_housing_client.execute("INSERT [dbo].[araction] (tag_ref, action_code, action_date) VALUES ('#{tenancy_ref}', '#{code}', '#{date}')").do
  end

  def truncate_uh_tables
    universal_housing_client.execute('TRUNCATE TABLE [dbo].[tenagree]').do
    universal_housing_client.execute('TRUNCATE TABLE [dbo].[rtrans]').do
    universal_housing_client.execute('TRUNCATE TABLE [dbo].[arag]').do
    universal_housing_client.execute('TRUNCATE TABLE [dbo].[araction]').do
  end

  def universal_housing_client
    Hackney::UniversalHousing::Client.connection
  end
end
