# TODO remove:
# ```
# :verbatim_type_locality,
# :type_specimen_repository,
# :type_specimen_code,
# :type_specimen_url
# ```

class AddTypeFieldsToTaxa < ActiveRecord::Migration
  def change
    add_column :taxa, :published_type_information, :text, nil: true
    add_column :taxa, :additional_type_information, :text, nil: true
    add_column :taxa, :type_notes, :text, nil: true
  end
end
