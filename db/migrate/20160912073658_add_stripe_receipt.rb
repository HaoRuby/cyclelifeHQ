class AddStripeReceipt < ActiveRecord::Migration
  def change
    exec_update(
      "ALTER TABLE stripe_transactions
       ADD
         receipt VARCHAR(1536)",
      "Added Stripe receipt column",
      [])
  end
end
