# frozen_string_literal: true

# The type localities in use (the distinct localities of protonyms), for the locality autocomplete of the protonym form.
class Locality
  def self.unique_sorted
    Protonym.distinct.pluck(:locality).compact.sort
  end
end
