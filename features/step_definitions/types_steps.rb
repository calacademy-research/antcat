# NOTE this creates a species with a type specimen repository because this is how we
# "create" type specimen repositories now before we have model for it.
Given(/^there is a type specimen repository "([^"]*)"$/) do |repository|
 create :species, type_specimen_repository: repository
end
