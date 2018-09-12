class AddAssignedUserIdToTenancies < ActiveRecord::Migration[5.1]
  def change
    add_column :tenancies, :assigned_user_id, :integer
  end
end
