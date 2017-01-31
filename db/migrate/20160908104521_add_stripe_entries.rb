class AddStripeEntries < ActiveRecord::Migration
  def change
    exec_update(
      "ALTER TABLE people
       ADD
         customer_token VARCHAR(64),
       ADD
         customer_active_token VARCHAR(64)",
      "Added Stripe columns to People",
      [])
  end
end

