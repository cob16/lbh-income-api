class RemoveIsPausedFromTenancies < ActiveRecord::Migration[5.1]
  def change
    remove_column :tenancies, :is_paused, :boolean
  end
end
