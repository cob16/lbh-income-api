class RenameTenanciesToCasePriorities < ActiveRecord::Migration[5.1]
  def self.up
    rename_table :tenancies, :case_priorities
  end

  def self.down
    rename_table :case_priorities, :tenancies
  end
end
