# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithDuplicatedTaxa < DatabaseScript
    def results
      Protonym.joins(:taxa).group('protonyms.id, taxa.name_cache').having('COUNT(*) > 1')
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Taxa', 'Statuses of taxa'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.author_citation,
            protonym.taxa.pluck(:name_cache).join('<br>'),
            protonym.taxa.pluck(:status).join('<br>')
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
category: Protonyms
tags: []

issue_description: This protonym has duplicated taxa.

description: >
  Duplicated as in having the same name.
