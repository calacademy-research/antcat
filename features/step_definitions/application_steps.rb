# frozen_string_literal: true

# General steps, specific to AntCat.

# HACK: To prevent the driver from navigating away from the page before completing the request.
def i_wait_for_the_success_message
  i_should_see "uccess" # "[Ss]uccess(fully)?"
end

def these_settings yaml_string
  hsh = YAML.safe_load(yaml_string)
  Settings.merge!(hsh)
end
