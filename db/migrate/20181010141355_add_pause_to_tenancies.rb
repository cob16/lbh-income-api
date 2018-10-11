class AddPauseToTenancies < ActiveRecord::Migration[5.1]
  def change
    add_column :tenancies, :is_paused, :boolean, default: false
  end
end
