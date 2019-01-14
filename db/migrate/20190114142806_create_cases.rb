class CreateCases < ActiveRecord::Migration[5.1]
  def change
    create_table :cases do |t|
      t.string :tenancy_ref

      t.timestamps
    end
  end
end
