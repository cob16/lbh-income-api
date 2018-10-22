class AddPauseUntilToTenancies < ActiveRecord::Migration[5.1]
  def change
    add_column :tenancies, :is_paused_until, :datetime, default: nil
  end
end
