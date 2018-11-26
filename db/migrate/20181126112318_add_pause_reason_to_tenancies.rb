class AddPauseReasonToTenancies < ActiveRecord::Migration[5.1]
  def change
    add_column :tenancies, :pause_reason, :string, default: nil
    add_column :tenancies, :pause_comment, :string, default: nil
  end
end
