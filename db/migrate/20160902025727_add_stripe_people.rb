class AddStripePeople < ActiveRecord::Migration
  def change
    add_column :people, :publishable_key, :string
    add_column :people, :provider, :string
    add_column :people, :uid, :string
    add_column :people, :access_code, :string
  end
end
