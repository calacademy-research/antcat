Given("SHOW_SOFT_VALIDATION_WARNINGS_IN_CATALOG is true") do
  stub_const "AntCat::SHOW_SOFT_VALIDATION_WARNINGS_IN_CATALOG", true
end

Given("there is an extant species Lasius niger in an fossil genus") do
  genus = create :genus, :fossil
  create :species, name_string: "Lasius niger", genus: genus
end

When("I open all database scripts once by one") do
  @browsed_scripts_count = 0

  script_names = DatabaseScript.all.map(&:to_param)
  script_names.each do |script_name|
    step %(I open the database script "#{script_name}")
  end
end

When("I open the database script {string}") do |database_script_name|
  visit "/database_scripts/#{database_script_name}"
  step 'I should see "Show source"' # Anything to confirm the page was rendered.
  @browsed_scripts_count += 1
end

# Confirm that the scenario didn't pass for the wrong reasons.
Then("I should have browsed at least 5 database scripts") do
  expect(@browsed_scripts_count).to be >= 5
end
