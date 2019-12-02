class AddUcReceivedToCasePriorty < ActiveRecord::Migration[5.2]
  def change
    add_column :case_priorities, :uc_direct_payment_received, :datetime
  end
end
