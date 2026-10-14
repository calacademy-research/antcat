# frozen_string_literal: true

# hamlit 4 renders attributes with double quotes; keep single quotes so the
# HTML AntCat produces (and its specs expect) is unchanged.
Hamlit::RailsTemplate.set_options(attr_quote: "'")
