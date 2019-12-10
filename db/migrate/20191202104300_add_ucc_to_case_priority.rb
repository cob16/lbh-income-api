class AddUccToCasePriority < ActiveRecord::Migration[5.2]
  def change
    add_column :case_priorities, :universal_credit, :datetime
  end
end
