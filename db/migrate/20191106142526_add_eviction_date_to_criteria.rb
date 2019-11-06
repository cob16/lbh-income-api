class AddEvictionDateToCriteria < ActiveRecord::Migration[5.2]
  def change
    add_column :case_priorities, :eviction_date, :datetime
  end
end
