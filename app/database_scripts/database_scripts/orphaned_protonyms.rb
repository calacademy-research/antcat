# frozen_string_literal: true

module DatabaseScripts
  class OrphanedProtonyms < DatabaseScript
    def results
      Protonym.where.not(id: Taxon.select(:protonym_id)).includes(:name)
    end

    def render
      as_table do |t|
        t.header 'ID', 'Protonym', 'Any WLHs?'
        t.rows do |protonym|
          [
            protonym.id,
            protonym.decorate.link_to_protonym,
            Protonyms::WhatLinksHere.new(protonym).any?
          ]
        end
      end
    end
  end
end

__END__

section: orphaned-records
category: Protonyms
tags: [slow-render]

issue_description: This protonym is orphaned.

description: >
  Orphaned protonyms can be deleted by editors from the protonym page, or by script on request (see %github430).

related_scripts:
  - OrphanedAuthorNames
  - OrphanedAuthors
  - OrphanedProtonyms
  - ProtonymsWithoutATerminalTaxon
