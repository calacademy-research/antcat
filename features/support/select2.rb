def select2(value, from:)
  element_id = from

  if value == '' # HACK because lazy.
    first("##{element_id}").set ''
    return
  end

  first("#select2-#{element_id}-container").click
  first('.select2-search__field').set(value)
  find(".select2-results__option", text: /#{Regexp.escape(value)}/).click
end

# No `from:` because we assume there will only be one open at any time.
def already_opened_select2(value)
  find('.select2-search__field').set value
  find(".select2-results__option", text: /#{value}/).click
end
