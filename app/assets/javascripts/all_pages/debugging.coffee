# Included in production as well, called in many places.
# Disabled because it makes the JS console too noisy.

$ ->
  AntCat.log = (message) ->
    return # Disabled, see above.
    unless typeof console == 'undefined'
      console.log message

  AntCat.check = (caller, object_name, object) ->
    return # Disabled, see above.
    return if object and object.size() == 1
    AntCat.log "#{caller}: #{object_name}.size() != 1"

  AntCat.check_nil = (caller, object_name, object) ->
    return # Disabled, see above.
    return if object
    AntCat.log "#{caller}: #{object_name} == nil"
