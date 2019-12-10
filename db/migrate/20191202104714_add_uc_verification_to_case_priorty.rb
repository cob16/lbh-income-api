class AddUcVerificationToCasePriorty < ActiveRecord::Migration[5.2]
  def change
    add_column :case_priorities, :uc_rent_verification, :datetime
  end
end
