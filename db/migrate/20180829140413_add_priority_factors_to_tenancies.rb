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

    add_column :tenancies, :balance, :decimal
    add_column :tenancies, :days_in_arrears, :decimal
    add_column :tenancies, :days_since_last_payment, :decimal
    add_column :tenancies, :payment_amount_delta, :decimal
    add_column :tenancies, :payment_date_delta, :decimal
    add_column :tenancies, :number_of_broken_agreements, :decimal
    add_column :tenancies, :active_agreement, :boolean
    add_column :tenancies, :broken_court_order, :boolean
    add_column :tenancies, :nosp_served, :boolean
    add_column :tenancies, :active_nosp, :boolean
  end
end
