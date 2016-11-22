# Included in production as well, called in many places.

$ ->
  AntCat.log = (message) ->
    unless typeof console == 'undefined'
      console.log message

  AntCat.check = (caller, object_name, object) ->
    return if object and object.size() == 1
    AntCat.log "#{caller}: #{object_name}.size() != 1"

  AntCat.check_nil = (caller, object_name, object) ->
    return if object
    AntCat.log "#{caller}: #{object_name} == nil"
