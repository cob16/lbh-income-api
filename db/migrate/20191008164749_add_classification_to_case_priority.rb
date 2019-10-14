class AddClassificationToCasePriority < ActiveRecord::Migration[5.2]
  def change
    add_column :case_priorities, :classification, :integer
  end
end
