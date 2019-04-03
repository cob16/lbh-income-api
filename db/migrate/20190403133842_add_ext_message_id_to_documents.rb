class AddExtMessageIdToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :ext_message_id, :string, default: nil
  end
end
