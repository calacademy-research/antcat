$ ->
  $('a.add-to-recently-used-references-js-hook').on 'ajax:success', ->
    $.notify "Added to recently used references",
      className: "success",
      autoHideDelay: 1500
