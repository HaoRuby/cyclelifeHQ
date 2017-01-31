class StripeController < ApplicationController

  def new
    @stripe = Stripe.new
  end

  def oauth
    url = client.authorize_url({
      scope: 'read_write',
      stripe_landing: 'register',
    })

    redirect_to url
  end

  def unlink
    flash[:notice] = "Your Stripe account has been un-linked from your CyclelifeHQ account."
    stripe_user = current_user
    stripe_user.update_attributes({
        :provider => "",
        :uid => "",
        :access_token => "", 
        :refresh_token => "",
        :publishable_key => ""
      })    

    redirect_to paypal_account_settings_payment_path(person_id: current_user.id)
  end

  def callback
    flash[:notice] = "Your Stripe account has been linked to your CyclelifeHQ account."
    @var = params[:code]
    stripe_return_code = params[:code]

    @data = client.get_token(stripe_return_code, {
      headers: {
        'grant_type' => "authorization_code",
        'scope' => "read_write"
      }
    } )

    save_token
    
    redirect_to paypal_account_settings_payment_path(person_id: current_user.id)
  end

  def save_token
    stripe_user = current_user
    stripe_user.update_attributes({
        :provider => "stripe",
        :uid => @data["stripe_user_id"],
        :access_token => @data.token,
        :refresh_token => @data.refresh_token,
        :publishable_key => @data["stripe_publishable_key"]
      })
  end

  def preauth
    stripe_token = params[:token]
    tx_id = params[:id]

    customer = Stripe::Customer.create(
      :source => stripe_token
      )
    unless current_user.customer_token?
      current_user.update_attributes({
         :customer_token => customer,
         :customer_active_token => stripe_token
        })
    else 
      current_user.update_attributes({
         :customer_active_token => stripe_token
        })
    end

    redirect_to person_transaction_path(person_id: current_user.id, locale: current_user.locale, id: tx_id)

  end

  private

  def client
    @client ||= OAuth2::Client.new(
    Rails.application.secrets.stripe_client_id,
    Rails.application.secrets.stripe_secret_key,
    {
      site: 'https://connect.stripe.com',
      authorize_url: '/oauth/authorize',
      token_url: '/oauth/token',
      scope: "read_write"
    }
    ).auth_code
  end


end
