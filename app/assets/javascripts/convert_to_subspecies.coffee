$ ->
  form = new AntCat.Form $('.convert_to_subspecies_form')

  new AntCat.NameField $('#new_species_id_field'),
    value_id: 'new_species_id'
    parent_form: form
    species_only: true
