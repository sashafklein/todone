$ ->

  toggleItem = (tr) ->
    value = $(tr).data 'value'
    button_text = if value then "Done!" else "Undo!"
    id = $(tr).data 'id'
    
    path = "/items/#{id}/toggle"

    $.post path, (response) ->
      if response.success
        $(tr).toggleClass 'to_archive'
        $(tr).find('p').html(button_text) 
        $(tr).data "value", !value

  $('.done').click (e) ->
    tr = $(e.target).closest('tr')
    toggleItem(tr)