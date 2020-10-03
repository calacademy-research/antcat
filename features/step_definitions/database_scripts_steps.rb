# frozen_string_literal: true

Given("there is an extant species Lasius niger in an fossil genus") do
  genus = create :genus, :fossil
  create :species, name_string: "Lasius niger", genus: genus
end

Given("I open all database scripts one by one") do
  script_names = DatabaseScript.all.map(&:to_param)
  script_names.each do |script_name|
    step %(I open the database script "#{script_name}")
  end
end

When("I open the database script {string}") do |database_script_name|
  visit "/database_scripts/#{database_script_name}"
  step 'I should see "Show source"' # Anything to confirm the page was rendered.
end
