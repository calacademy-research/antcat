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

def already_opened_select2(value, from:) # rubocop:disable Lint/UnusedMethodArgument
  # TODO figure out why this isn't used or remove.
  # element_id = from

  find('.select2-search__field').set value
  find(".select2-results__option", text: /#{value}/).click
end
