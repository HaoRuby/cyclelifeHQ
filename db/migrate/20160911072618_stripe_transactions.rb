class StripeTransactions < ActiveRecord::Migration
  def change
    create_table :stripe_transactions do |t|
      t.integer :transaction_id
      t.string :sender_id
      t.string :recipient_id
      t.float :amount
      t.timestamps :created_at, :datetime
    end
  end
end
