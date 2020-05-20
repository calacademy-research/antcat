# frozen_string_literal: true

# TODO: Remove - keyword:type_taxt.
module DatabaseScripts
  class MoveTypeTaxonToProtonymByScript < DatabaseScript
    def results
      Taxon.where.not(type_taxon: nil).includes(:type_taxon, protonym: [:name, :type_name])
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Protonym', 'Type taxon (old)', 'type_taxt', 'Proronym TT', 'expanded fixation_method'
        t.rows do |taxon|
          type_taxon = taxon.type_taxon
          protonym = taxon.protonym
          protonym_type_name_taxon = protonym.type_name&.taxon
          fixation_method = protonym.type_name&.decorate&.format_fixation_method

          [
            taxon_link(taxon),
            protonym.decorate.link_to_protonym,
            taxon_link(type_taxon),
            taxon.type_taxt,
            (CatalogFormatter.link_to_taxon(protonym_type_name_taxon) if protonym_type_name_taxon),
            fixation_method
          ]
        end
      end
    end
  end
end

__END__

section: pa-action-required
category: Protonyms
tags: [updated!, slow]

description: >
  `type_taxt` contains the old data for comparison (it cannot be updated).


  `expanded fixation_method` contains the same data but in a new database table (update it in the protonym form).
