module Taxa
  class AttributesForNewUsage
    include Service

    def initialize new_comb, old_comb
      @new_comb = new_comb
      @old_comb = old_comb
    end

    def call
      {
        name_attributes: { id: name_id },
        status: Status::VALID,
        homonym_replaced_by_id: old_comb.homonym_replaced_by_id,
        current_valid_taxon_id: old_comb.current_valid_taxon_id,
        incertae_sedis_in: old_comb.incertae_sedis_in,
        fossil: old_comb.fossil,
        nomen_nudum: old_comb.nomen_nudum,
        unresolved_homonym: old_comb.unresolved_homonym,
        ichnotaxon: old_comb.ichnotaxon,
        hong: old_comb.hong,
        headline_notes_taxt: old_comb.headline_notes_taxt || "",
        biogeographic_region: old_comb.biogeographic_region,
        published_type_information: old_comb.published_type_information,
        additional_type_information: old_comb.additional_type_information,
        type_notes: old_comb.type_notes,
        protonym_attributes: {
          name_attributes: { id: old_comb.protonym.name_id },
          fossil: old_comb.protonym.fossil,
          sic: old_comb.protonym.sic,
          locality: old_comb.protonym.locality,
          id: old_comb.protonym_id,
          authorship_attributes: {
            reference_attributes: { id: old_comb.protonym.authorship.reference_id },
            pages: old_comb.protonym.authorship.pages,
            forms: old_comb.protonym.authorship.forms,
            notes_taxt: old_comb.protonym.authorship.notes_taxt || "",
            id: old_comb.protonym.authorship_id
          }
        }
      }
    end

   private

     attr_reader :new_comb, :old_comb

     def name_id
       new_comb.name ? new_comb.name.id : old_comb.name.id
     end
  end
end
