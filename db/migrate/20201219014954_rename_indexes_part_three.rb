# frozen_string_literal: true

class RenameIndexesPartThree < ActiveRecord::Migration[6.1]
  def change
    rename_index :history_items, 'ix_history_items__object_taxon_id__taxa__id',
      'ix_history_items__object_taxon_id'

    rename_index :taxa, 'index_taxa_on_current_taxon_id', 'ix_taxa__current_taxon_id'
    rename_index :taxa, 'index_taxa_on_family_id', 'ix_taxa__family_id'
    rename_index :taxa, 'taxa_genus_id_idx', 'ix_taxa__genus_id'
    rename_index :taxa, 'index_taxa_on_homonym_replaced_by_id', 'ix_taxa__homonym_replaced_by_id'
    rename_index :taxa, 'taxa_id_and_type_idx', 'ix_taxa__id__type'
    rename_index :taxa, 'index_taxa_on_name_cache', 'ix_taxa__name_cache'
    rename_index :taxa, 'taxa_name_id_idx', 'ix_taxa__name_id'
    rename_index :taxa, 'index_taxa_on_protonym_id', 'ix_taxa__protonym_id'
    rename_index :taxa, 'taxa_species_id_index', 'ix_taxa__species_id'
    rename_index :taxa, 'index_taxa_on_status', 'ix_taxa__status'
    rename_index :taxa, 'taxa_subfamily_id_idx', 'ix_taxa__subfamily_id'
    rename_index :taxa, 'index_taxa_on_subgenus_id', 'ix_taxa__subgenus_id'
    rename_index :taxa, 'fk_taxa__subspecies_id__taxa__id', 'ix_taxa__subspecies_id'
    rename_index :taxa, 'taxa_tribe_id_idx', 'ix_taxa__tribe_id'
    rename_index :taxa, 'taxa_type_idx', 'ix_taxa__type'

    rename_index :type_names, 'index_type_names_on_reference_id', 'ix_type_names__reference_id'
    rename_index :type_names, 'index_type_names_on_taxon_id', 'ix_type_names__taxon_id'

    rename_index :users, 'index_users_on_author_id', 'ux_users__author_id'
    rename_index :users, 'index_users_on_email', 'ux_users__email'
    rename_index :users, 'index_users_on_reset_password_token', 'ux_users__reset_password_token'

    rename_index :versions, 'index_versions_on_event', 'ix_versions__event'
    rename_index :versions, 'index_versions_on_item_id', 'ix_versions__item_id'
    rename_index :versions, 'index_versions_on_item_type_and_item_id', 'ix_versions__item_type__item_id'
    rename_index :versions, 'index_versions_on_request_uuid', 'ix_versions__request_uuid'
    rename_index :versions, 'index_versions_on_whodunnit', 'ix_versions__whodunnit'

    reversible do |dir|
      dir.up do
        remove_index :taxa, name: :taxa_homonym_resolved_to_id_index
      end
      dir.down do
        add_index :taxa, :homonym_replaced_by_id, name: :taxa_homonym_resolved_to_id_index
      end
    end
  end
end
