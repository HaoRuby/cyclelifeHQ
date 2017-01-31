Rails.application.config.middleware.use OmniAuth::Builder do
#   #$provider :stripe_connect, ENV['STRIPE_CONNECT_CLIENT_ID'], ENV['STRIPE_SECRET']
  provider :stripe_connect, 'ca_97IvYDwqhmxwnRCrf1LmtF5tM1qSNyKy', 'sk_test_A4PMfoSce6mRbqgMhan4tIk8'
  provider :stripe_connect, :callback_path => "/stripe/stripe_connect/callback/"
end

