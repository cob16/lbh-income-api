class RemoveAssignedUserIdFromTenancies < ActiveRecord::Migration[5.1]
  def change
    remove_column :tenancies, :assigned_user_id, :integer
  end
end
