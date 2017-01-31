$(document).ready ->
  return unless StripeCheckout?

  is_submitted = false

  payButton = $('.pay-button')
  form = payButton.closest('form')
  handler = null

  stripeHandler = ->
    handler = StripeCheckout.configure
      key: window.publishable_key
      description: window.description
      amount: window.payment_amount
      email: window.current_user_email
      image: window.image
      zipCode: true

      allowRememberMe: false
      token: (token) ->
        is_submitted = true
        form.find('input[name=stripe_token]').val(token.id)
        $('#stripe_token').val(token.id)
        form.get(0).submit()

  stripeHandler()

  payButton.click (e) ->
    e.preventDefault()

    handler.open
      name: 'CyclelifeHQ'

