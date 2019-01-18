class CreateCases < ActiveRecord::Migration[5.1]
  def change
    create_table :cases do |t|
      t.string :tenancy_ref, unique: true

      t.timestamps
    end
  end
end
