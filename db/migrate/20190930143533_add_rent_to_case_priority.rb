class AddRentToCasePriority < ActiveRecord::Migration[5.2]
  def change
    add_column :case_priorities, :weekly_rent, :decimal, precision: 10, scale: 2
  end
end
