class AddSelectListing < ActiveRecord::Migration
  def change
    exec_update(
      "ALTER TABLE listings
       ADD
         selcat varchar(50),
      ADD
         selsub varchar(50),
      ADD
         selsha varchar(50)",
      "Added columns for related listings",
      [])

  end
end
