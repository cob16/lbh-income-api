class AddPatchCodeToCasePriorities < ActiveRecord::Migration[5.2]
  def change
    add_column :case_priorities, :patch_code, :string
  end
end
