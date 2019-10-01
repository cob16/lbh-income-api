class AddLastCommunicationDate < ActiveRecord::Migration[5.2]
  def change
    add_column :case_priorities, :last_communication_date, :datetime

  end
end
