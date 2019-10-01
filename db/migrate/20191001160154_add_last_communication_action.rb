class AddLastCommunicationAction < ActiveRecord::Migration[5.2]
  def change
    add_column :case_priorities, :last_communication_action, :string, default: nil
  end
end
