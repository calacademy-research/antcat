# frozen_string_literal: true

module DatabaseScripts
  class TaxaThatAppearsMoreThanOnceInTypeNames < DatabaseScript
    def results
      Taxon.where(id: TypeName.group(:taxon_id).having('COUNT(id) > 1').select(:taxon_id)).limit(100)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'TypeName record protonyms'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.status,
            protonym_links(taxon.type_names.map(&:protonym))
          ]
        end
      end
    end
  end
end

__END__

title: Taxa that appears more than once in <code>TypeName</code>s

section: research
category: Types
tags: [new!]

description: >

related_scripts:
  - TaxaThatAppearsMoreThanOnceInTypeNames
