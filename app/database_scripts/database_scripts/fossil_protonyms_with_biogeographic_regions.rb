# frozen_string_literal: true

module DatabaseScripts
  class FossilProtonymsWithBiogeographicRegions < DatabaseScript
    def results
      Protonym.fossil.where.not(biogeographic_region: nil)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Biogeographic region'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.biogeographic_region
          ]
        end
      end
    end
  end
end

__END__

section: main
category: Protonyms
tags: [new!]

issue_description:

description: >
  See %github389

related_scripts:
  - FossilProtonymsWithBiogeographicRegions
