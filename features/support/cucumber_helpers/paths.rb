# frozen_string_literal: true

module CucumberHelpers
  module Paths
    def path_to page_name
      case page_name

      when 'the main page'
        root_path

      # Catalog.
      when 'the advanced search page'
        catalog_search_path

      when /^the catalog page for "([^"]*)"$/
        taxon = Taxon.find_by(name_cache: Regexp.last_match(1))
        "/catalog/#{taxon.id}"
      when 'the catalog'
        root_path

      # Editing (catalog).
      when /^the edit page for "(.*)"$/
        "/taxa/#{Taxon.find_by(name_cache: Regexp.last_match(1)).id}/edit"
      when 'the new taxon page'
        "/taxa/new"

      when 'the protonyms page'
        protonyms_path

      # References, authors, etc.
      when 'the references page'
        references_path
      when 'the latest reference additions page'
        references_latest_additions_path
      when 'the page of the most recent reference'
        reference_path(Reference.last)
      when 'the page of the oldest reference'
        reference_path(Reference.first)
      when /^the page of the reference "([^"]*)"$/
        reference = find_reference_by_keey Regexp.last_match(1)
        reference_path(reference)
      when 'the edit page for the most recent reference'
        edit_reference_path(Reference.last)

      when 'the authors page'
        authors_path
      when /^the author page for "(.*)"$/
        author = AuthorName.find_by(name: Regexp.last_match(1)).author
        "/authors/#{author.id}"

      # Editor's Panel.
      when "the Editor's Panel"
        "/panel"

      when 'the comments page'
        "/comments"

      when 'the institutions page'
        "/institutions"

      when 'my notifications page'
        "/notifications"

      when 'the database scripts page'
        "/database_scripts"

      when 'the site notices page'
        "/site_notices"

      when 'the tooltips page'
        "/tooltips"

      when 'the activity feed'
        "/activities"

      when 'the versions page'
        "/panel/versions"

      when 'the open issues page'
        "/issues"
      when /^the issue page for "([^"]*)"$/
        issue = Issue.find_by(title: Regexp.last_match(1))
        "/issues/#{issue.id}"
      when 'the new issue page'
        "/issues/new"

      when 'the feedback page'
        "/feedback"
      when 'the most recent feedback item'
        "/feedback/#{Feedback.last.id}"

      when 'the wiki pages index'
        "/wiki_pages"

      # Reference sections and taxon history items.
      when 'the reference sections page'
        "/reference_sections"
      when 'the page of the most recent reference section'
        reference_section_path(ReferenceSection.last)
      when 'the taxon history items page'
        "/taxon_history_items"
      when 'the page of the most recent history item'
        taxon_history_item_path(TaxonHistoryItem.last)

      # Users.
      when /^the user page for "([^"]*)"$/
        user = User.find_by(name: Regexp.last_match(1))
        "/users/#{user.id}"
      when 'the login page'
        '/my/users/sign_in'
      when 'the users page'
        '/users'

      else
        raise "#{page_name} not found"
      end
    end
  end
end

World CucumberHelpers::Paths
