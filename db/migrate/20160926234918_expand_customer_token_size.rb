class ExpandCustomerTokenSize < ActiveRecord::Migration
  def change
    exec_update(
      "ALTER TABLE people
       CHANGE
         customer_token customer_token VARCHAR(1536)",
      "Increased size of customer_token",
      [])
  end
end
