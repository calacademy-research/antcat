# frozen_string_literal: true

def i_should_see_number_of_versions count
  all "table tbody tr", count: count
end
