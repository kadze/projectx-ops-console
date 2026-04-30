class AddInternalNotesToUsers < ActiveRecord::Migration[6.1]
  def change
    return if column_exists?(:users, :internal_notes)
    add_column :users, :internal_notes, :text
  end
end
