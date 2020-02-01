$ ->
  $('a.add-to-recently-used-references-js-hook').on 'ajax:success',
    -> AntCat.notifySuccess("Added to recently used references")
