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
        taxon = Taxon.find_by!(name_cache: Regexp.last_match(1))
        catalog_path(taxon)
      when 'the catalog'
        root_path

      # Editing (catalog).
      when /^the edit page for "(.*)"$/
        taxon = Taxon.find_by!(name_cache: Regexp.last_match(1))
        edit_taxa_path(taxon)

      when 'the protonyms page'
        protonyms_path
      when /^the edit page for the protonym "(.*)"$/
        protonym = Protonym.joins(:name).find_by!(names: { name: Regexp.last_match(1) })
        edit_protonym_path(protonym)

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
        reference = ReferenceStepsHelpers.find_reference_by_key(Regexp.last_match(1))
        reference_path(reference)
      when 'the edit page for the most recent reference'
        edit_reference_path(Reference.last)

      when 'the authors page'
        authors_path
      when /^the author page for "(.*)"$/
        author = AuthorName.find_by!(name: Regexp.last_match(1)).author
        author_path(author)

      # Editor's Panel.
      when "the Editor's Panel"
        editors_panel_path

      when 'the comments page'
        comments_path

      when 'the institutions page'
        institutions_path

      when 'my notifications page'
        notifications_path

      when 'the database scripts page'
        database_scripts_path

      when 'the site notices page'
        site_notices_path

      when 'the activity feed'
        activities_path

      when 'the versions page'
        versions_path

      when 'the open issues page'
        issues_path
      when /^the issue page for "([^"]*)"$/
        issue = Issue.find_by!(title: Regexp.last_match(1))
        issue_path(issue)
      when 'the new issue page'
        new_issue_path

      when 'the feedback page'
        feedbacks_path
      when 'the most recent feedback item'
        feedback_path(Feedback.last)

      when 'the wiki pages index'
        wiki_pages_path

      # Reference sections and taxon history items.
      when 'the reference sections page'
        reference_sections_path
      when 'the page of the most recent reference section'
        reference_section_path(ReferenceSection.last)
      when 'the taxon history items page'
        taxon_history_items_path
      when 'the page of the most recent history item'
        taxon_history_item_path(TaxonHistoryItem.last)

      # Users.
      when 'My account'
        edit_user_registration_path
      when /^the user page for "([^"]*)"$/
        user = User.find_by!(name: Regexp.last_match(1))
        user_path(user)
      when 'the login page'
        new_user_session_path
      when 'the users page'
        users_path

      else
        raise "#{page_name} not found"
      end
    end
  end
end

World CucumberHelpers::Paths
