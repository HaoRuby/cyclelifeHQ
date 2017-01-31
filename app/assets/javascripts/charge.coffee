$(document).ready ->
  if !StripeCheckout
    return

  is_submitted = false #prevent duplicate submissions

  stripePay = $('.stripe-button')
  #attached to nearest form
  stripeForm = stripePay.closest('form')
  destination = form.find('select[name=charge_on]')
  indicator = form.find('.indicator').height( form.outerHeight() )
  handler = null

  createHandler = ->
    handler = StripeCheckout.configure
      key: window.key

      # The email of the logged in user.
      email: window.currentUserEmail

      allowRememberMe: false
      closed: ->
        form.removeClass('processing') unless submitting
      token: ( token ) ->
        submitting = true
        form.find('input[name=token]').val( token.id )
        form.get(0).submit()

  destination.change createHandler
  createHandler()

  stripePay.click ( e ) ->
    e.preventDefault()
    form.addClass( 'processing' )

    handler.open
      name: 'Rails Connect Example'
      description: '$10 w/ 10% fees'
      amount: 1000
