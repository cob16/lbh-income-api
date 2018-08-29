class AddPriorityFactorsToTenancies < ActiveRecord::Migration[5.1]
  def change
    add_column :tenancies, :balance_contribution, :decimal
    add_column :tenancies, :days_in_arrears_contribution, :decimal
    add_column :tenancies, :days_since_last_payment_contribution, :decimal
    add_column :tenancies, :payment_amount_delta_contribution, :decimal
    add_column :tenancies, :payment_date_delta_contribution, :decimal
    add_column :tenancies, :number_of_broken_agreements_contribution, :decimal
    add_column :tenancies, :active_agreement_contribution, :decimal
    add_column :tenancies, :broken_court_order_contribution, :decimal
    add_column :tenancies, :nosp_served_contribution, :decimal
    add_column :tenancies, :active_nosp_contribution, :decimal
  end
end
