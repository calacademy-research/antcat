# frozen_string_literal: true

module FeatureHelpers
  module Paths
    def path_to page_name
      case page_name

      when 'the main page'
        root_path

      # Catalog.
      when /^the catalog page for "([^"]*)"$/
        taxon = Taxon.find_by!(name_cache: Regexp.last_match(1))
        catalog_path(taxon)

      # Editing (catalog).
      when /^the edit page for "(.*)"$/
        taxon = Taxon.find_by!(name_cache: Regexp.last_match(1))
        edit_taxon_path(taxon)

      when 'the protonyms page'
        protonyms_path
      when /^the protonym page for "(.*)"$/
        protonym = Protonym.joins(:name).find_by!(names: { name: Regexp.last_match(1) })
        protonym_path(protonym)

      # References, authors, etc.
      when 'the references page'
        references_path
      when 'the latest reference additions page'
        references_latest_additions_path

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
      when 'the new issue page'
        new_issue_path

      when 'the feedback page'
        feedbacks_path

      when 'the wiki pages index'
        wiki_pages_path

      # Reference sections and history items.
      when 'the reference sections page'
        reference_sections_path
      when 'the history items page'
        history_items_path

      # Users.
      when 'My account'
        edit_user_registration_path
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
