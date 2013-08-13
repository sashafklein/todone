$ ->
  $('.done').on 'click', (e) ->
    if confirm "Are you sure? This is final."
      tr = $(e.target).closest('tr')
      path = $(tr).data "path"
      
      $.post path, (response) ->
        if response.success
          $(tr).hide(1000)