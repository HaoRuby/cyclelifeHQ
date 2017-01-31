class AlterStripeEntries < ActiveRecord::Migration
  def up
    exec_update(
      "ALTER TABLE people
       CHANGE 
         access_code access_token VARCHAR(64),
       CHANGE 
         provider provider VARCHAR(20),
       CHANGE 
         uid uid VARCHAR(64),
       CHANGE 
         publishable_key publishable_key VARCHAR(64),
       ADD
         refresh_token VARCHAR(64)",
      "Changes to Stripe columns",
      [])
  end
end
