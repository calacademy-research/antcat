# This clears the cache in all envs. That's ok.
Given(/^all database script caches are cleared$/) do
  Rails.cache.delete_matched(/^db_scripts\//)
end

Given(/^there is a Lasius subspecies without a species$/) do
  subspecies = create_subspecies "Lasius specius subspecius", species: nil
  expect(subspecies.species).to be nil
end

When(/^I open all database scripts and browse their sources$/) do
  @browsed_scripts_count = 0

  script_names = DatabaseScript.all.map &:to_param
  script_names.each do |script_name|
    step %{I open the database script "#{script_name}" and browse its source}
  end
end

When(/^I open the database script "([^"]*)" and browse its source$/) do |script_name|
  visit "/database_scripts/#{script_name}"

  step %{I should see "Show source"}
  step %{I follow "current (antcat.org)"}
  step %{I should see "Back to script"}

  @browsed_scripts_count += 1
end

# Confirm that the scenario didn't pass for the wrong reasons.
Then(/^I should have browsed at least 5 database scripts$/) do
  expect(@browsed_scripts_count).to be >= 5
end

Given(/^the genus Atta has a protonym with a missing reference$/) do
  reference = create :missing_reference, citation: "Batiatus 2000"
  taxon = create_genus "Atta"
  taxon.protonym.authorship.reference = reference
  taxon.save!
end
