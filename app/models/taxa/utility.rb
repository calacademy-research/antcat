class Taxa::Utility
  # TODO probably safe to move to Genus
  # target_epithet is a string, genus is an object
  def self.find_epithet_in_genus target_epithet, genus
    Name.make_epithet_set(target_epithet).each do |epithet|
      results = Taxon.with_names.where(genus: genus)
        .where(["names.epithet = ?", epithet])
      return results unless results.empty?
    end
    nil
  end

  def self.find_subspecies_in_genus target_subspecies, genus
    Name.make_epithet_set(target_subspecies).each do |epithet|
      results = Taxon.with_names.where(genus: genus)
        .where(["names.epithet = ?", epithet])
      return results unless results.empty?
    end
    nil
  end

  def self.inherit_attributes_for_new_combination new_comb, old_comb, new_comb_parent
    new_comb.name =
      if new_comb_parent.is_a? Species
        Name.parse [ new_comb_parent.name.genus_epithet,
                     new_comb_parent.name.species_epithet,
                     old_comb.name.epithet ].join(' ')
      else
        Name.parse [ new_comb_parent.name.genus_epithet, old_comb.name.species_epithet ].join(' ')
      end

    new_comb.protonym = old_comb.protonym
    new_comb.verbatim_type_locality = old_comb.verbatim_type_locality
    new_comb.biogeographic_region = old_comb.biogeographic_region
    new_comb.type_specimen_repository = old_comb.type_specimen_repository
    new_comb.type_specimen_code = old_comb.type_specimen_code
    new_comb.type_specimen_url = old_comb.type_specimen_url
  end

  def self.attributes_for_new_usage new_comb, old_comb
    {
      name_attributes: { id: new_comb.name ? new_comb.name.id : old_comb.name.id },
      status: 'valid',
      homonym_replaced_by_name_attributes: {
          id: old_comb.homonym_replaced_by ? old_comb.homonym_replaced_by.name_id : nil},
      current_valid_taxon_name_attributes: {
          id: old_comb.current_valid_taxon ? old_comb.current_valid_taxon.name_id : nil},
      incertae_sedis_in: old_comb.incertae_sedis_in,
      fossil: old_comb.fossil,
      nomen_nudum: old_comb.nomen_nudum,
      unresolved_homonym: old_comb.unresolved_homonym,
      ichnotaxon: old_comb.ichnotaxon,
      hong: old_comb.hong,
      headline_notes_taxt: old_comb.headline_notes_taxt || "",
      biogeographic_region: old_comb.biogeographic_region,
      verbatim_type_locality: old_comb.verbatim_type_locality,
      type_specimen_repository: old_comb.type_specimen_repository,
      type_specimen_code: old_comb.type_specimen_code,
      type_specimen_url: old_comb.type_specimen_url,
      protonym_attributes: {
          name_attributes: {
              id: old_comb.protonym.name_id },
          fossil: old_comb.protonym.fossil,
          sic: old_comb.protonym.sic,
          locality: old_comb.protonym.locality,
          id: old_comb.protonym_id,
          authorship_attributes: {
              reference_attributes: {
                  id: old_comb.protonym.authorship.reference_id },
              pages: old_comb.protonym.authorship.pages,
              forms: old_comb.protonym.authorship.forms,
              notes_taxt: old_comb.protonym.authorship.notes_taxt || "",
              id: old_comb.protonym.authorship_id
          }
      }
    }
  end
end
