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

      when /^the protonym page for "(.*)"$/
        protonym = Protonym.joins(:name).find_by!(names: { name: Regexp.last_match(1) })
        protonym_path(protonym)

      # References, authors, etc.
      when 'the references page'
        references_path

      when /^the author page for "(.*)"$/
        author = AuthorName.find_by!(name: Regexp.last_match(1)).author
        author_path(author)

      # Editor's Panel.
      when 'the institutions page'
        institutions_path

      # Users.
      when 'the login page'
        new_user_session_path

      else
        raise "#{page_name} not found"
      end
    end
  end
end
