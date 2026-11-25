# frozen_string_literal: true

# The "Policies and help" section: policies, names with notes, help pages (the wiki) and institutions. Public, and
# the same for a visitor and an editor: none of these pages sits below the Editor's Panel.
crumb :policies_and_help do
  link "Policies and help", wiki_pages_path(policies: 1)
end

crumb :policies do
  link "Policies", wiki_pages_path(policies: 1)
  parent :policies_and_help
end

crumb :notes_pages do
  link "Names with notes", notes_pages_path
  parent :policies_and_help
end
