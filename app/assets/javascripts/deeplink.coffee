$(document).ready ->
  return unless window.deeplink?

  $('.deeplink-button').click (e) ->
    e.preventDefault()
    window.open(window.deeplink, "_blank")

