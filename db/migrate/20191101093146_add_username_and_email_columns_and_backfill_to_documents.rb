class AddUsernameAndEmailColumnsAndBackfillToDocuments < ActiveRecord::Migration[5.2]
  def up
    add_column :documents, :username, :string
    add_column :documents, :email, :string

    Hackney::Cloud::Document.find_each do |document|
      next if document.metadata.blank?

      metadata = JSON.parse(document.metadata)

      user = Hackney::Income::Models::User.find_by(id: metadata['user_id'])

      next if user.blank?

      document.update!(username: user.name, email: user.email)
    end
  end

  def down
    remove_column :documents, :username, :string
    remove_column :documents, :email, :string
  end
end
