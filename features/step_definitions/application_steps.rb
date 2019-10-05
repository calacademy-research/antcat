# General steps, specific to AntCat.

When("I follow {string} inside the breadcrumb") do |link|
  within "#breadcrumbs" do
    step %(I follow "#{link}")
  end
end

# HACK: To prevent the driver from navigating away from the page before completing the request.
And('I wait for the "success" message') do
  step 'I should see "uccess"' # "[Ss]uccess(fully)?"
end
