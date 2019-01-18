class CreateFkOnCasePrioritiesToCases < ActiveRecord::Migration[5.1]
  def change
    change_table :case_priorities do |t|
      t.references :case
    end
  end
end
