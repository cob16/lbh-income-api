class CreateFkOnCasePrioritiesToCases < ActiveRecord::Migration[5.1]
  def change
    add_column :case_priorities, :case_id, :integer
    add_index :case_priorities, :case_id, unique: true
    add_foreign_key :case_priorities, :cases
  end
end
