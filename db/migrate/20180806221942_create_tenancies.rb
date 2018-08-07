class CreateTenancies < ActiveRecord::Migration[5.1]
  def change
    create_table :tenancies do |t|
      t.string :tenancy_ref
      t.string :priority_band
      t.integer :priority_score
      t.timestamps
    end
  end
end
