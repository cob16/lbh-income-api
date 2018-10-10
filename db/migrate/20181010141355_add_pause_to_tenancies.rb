class AddPauseToTenancies < ActiveRecord::Migration[5.1]
  def change
    add_column :tenancies, :pause_status, :boolean, default: false
  end
end
