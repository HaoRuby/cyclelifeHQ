Rails.configuration.stripe = {
#	:publishable_key => ENV['PUBLISHABLE_KEY'],
#	:secret_key      => ENV['STRIPE_SECRET_KEY']
    :publishable_key => Rails.application.secrets.stripe_publishable_key,
    :secret_key      => Rails.application.secrets.stripe_secret_key,
    :client_id       => Rails.application.secrets.stripe_client_id

}

Stripe.api_key = Rails.application.secrets.stripe_secret_key
