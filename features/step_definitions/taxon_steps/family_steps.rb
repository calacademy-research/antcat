# frozen_string_literal: true

Given("the Formicidae family exists") do
  the_formicidae_family_exists
end
def the_formicidae_family_exists
  create :family, name_string: "Formicidae"
end
