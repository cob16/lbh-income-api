class AddUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :provider_uid
      t.string :provider
      t.string :name
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :provider_permissions
    end

    add_reference :tenancies, :assigned_user, foreign_key: { to_table: :users }
  end
end
