class AddDeepLinks < ActiveRecord::Migration
  def change
    exec_update(
      "ALTER TABLE listings
       ADD
         deep_link VARCHAR(256)",
      "Added columns for deep links",
      [])
  end
end
