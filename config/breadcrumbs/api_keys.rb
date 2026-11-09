# frozen_string_literal: true

crumb :api_key do
  link "Free API Key", new_api_key_path
  parent :antcat
end

crumb :panel_api_keys do
  link "API Keys", panel_api_keys_path
  parent :editors_panel
end

crumb :edit_panel_api_key do |api_key|
  link "API Key ##{api_key.id}"
  parent :panel_api_keys
end
