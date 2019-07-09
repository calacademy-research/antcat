def select2(value, from:)
  element_id = from

  if value == '' # HACK: Because lazy.
    first("##{element_id}").set ''
    return
  end

  first("#select2-#{element_id}-container").click
  first('.select2-search__field').set(value)
  find(".select2-results__option", text: /#{Regexp.escape(value)}/).click
end
