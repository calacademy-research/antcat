# frozen_string_literal: true

# General steps, specific to AntCat.

# HACK: To prevent the driver from navigating away from the page before completing the request.
And('I wait for the "success" message') do
  step 'I should see "uccess"' # "[Ss]uccess(fully)?"
end
