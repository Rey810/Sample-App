class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :email, unique: true  #add_index is a rails method to add an index on the email column of the users table
  end
end
