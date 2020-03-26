# frozen_string_literal: true

module DatabaseScripts
  class TaxaWithNonModernCapitalization < DatabaseScript
    def results
      Taxon.joins(:name).where("name NOT LIKE '%(%' AND BINARY SUBSTRING(name, 2) != LOWER(SUBSTRING(name, 2))")
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status'
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status
          ]
        end
      end
    end
  end
end

__END__

title: Taxa with non-modern capitalization
category: Catalog
tags: [regression-test]

issue_description: The name of this taxon contains non-modern capitalization.

description: >
  See %github831.
