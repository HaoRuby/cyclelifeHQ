# == Schema Information
#
# Table name: stripe_transactions
#
#  id             :integer          not null, primary key
#  transaction_id :integer
#  sender_id      :string(255)
#  recipient_id   :string(255)
#  amount         :float(24)
#  created_at     :datetime
#  updated_at     :datetime
#  receipt        :string(3096)
#

class StripeTrans < ActiveRecord::Base
	self.table_name="stripe_transactions"
  validates :transaction_id, presence: true
  validates :sender_id, presence: true
  validates :recipient_id, presence: true

  
  def new
  	@trans = StripeTrans.new
	@card_errors = {
		invalid_number: "There is a problem with the card number",
		incorrect_number: "There is a problem with the card number",
		invalid_expiry_month: "There is a problem with the expiry date.",
		invalid_expiry_year: "There is a problem with the expiry date.",
		invalid_cvc: "There is a problem with the security code.",
		incorrect_cvc: "There is a problem with the security code.",
		incorrect_zip: "There is a problem with the postal code.",
		card_declines: "The card was declined.",
		processing_error: "An error occurred while processing the card."
	}	
  end

  def get_fee
  	#get dynamically later
  	@fee = Rails.application.secrets.fee_percent;
  end

  def charge_preauth(transaction_id, community_id)
    trans = StripeTrans.new
    transaction_conversation = MarketplaceService::Transaction::Query.transaction(transaction_id)
    result = TransactionService::Transaction.get(community_id: community_id, transaction_id: transaction_id)
    transaction = result[:data]
    amount=transaction[:checkout_total];
    recipient_id=transaction[:listing_author_id]
    sender_id=transaction[:starter_id]

    #get customer ID
    customer = JSON.parse(Person.find(sender_id).customer_token)
	Rails.logger.warn "CUSTOMER: #{customer}"
	Rails.logger.warn "CUSTOMER_ID: #{customer['id']}"

    seller = Person.find(recipient_id).uid

   	get_fee
   	charge_amount = (100*(amount.to_i))
   	@fee = (charge_amount*@fee).to_i
   	Rails.logger.warn "APP: #{@fee}"

   	begin
    charge = Stripe::Charge.create({
    	:amount => charge_amount,
    	:currency => "aud",
    	:customer => customer['id'],
    	:application_fee => @fee,
    	:destination => seller
    	})
    
    rescue Stripe::CardError => e
    	return trans.card_errors(e)
	end

	#write receipt
    trans = StripeTrans.create(sender_id: sender_id, transaction_id: transaction_id, recipient_id: recipient_id, amount: amount, receipt: charge)
    return "success"
  end
end

