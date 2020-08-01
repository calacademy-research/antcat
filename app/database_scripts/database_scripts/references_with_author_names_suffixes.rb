# frozen_string_literal: true

module DatabaseScripts
  class ReferencesWithAuthorNamesSuffixes < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

    def results
      Reference.order_by_author_names_and_year.where.not(author_names_suffix: [nil, ''])
    end

    def render
      as_table do |t|
        t.header 'Reference', 'author_names_suffix'
        t.rows do |reference|
          [
            link_to(reference.key_with_citation_year, reference_path(reference)),
            reference.author_names_suffix
          ]
        end
      end
    end
  end
end

__END__

title: References with <code>author_names_suffix</code>es

section: research
category: References
tags: [list]

description: >
  Not an issue. Script was added to get an overview of all `author_names_suffix`es.

related_scripts:
  - ReferencesWithAuthorNamesSuffixes
