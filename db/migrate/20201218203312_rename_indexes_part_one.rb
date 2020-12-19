# frozen_string_literal: true

class RenameIndexesPartOne < ActiveRecord::Migration[6.1]
  def change
    rename_index :activities, 'index_activities_on_request_uuid', 'ix_activities__request_uuid'
    rename_index :activities, 'index_activities_on_trackable_id_and_trackable_type',
      'ix_activities__trackable_id__trackable_type'
    rename_index :activities, 'index_activities_on_user_id', 'ix_activities__user_id'

    rename_index :author_names, 'author_names_author_id_idx', 'ix_author_names__author_id'
    rename_index :author_names, 'author_created_at_name', 'ix_author_names__created_at__name'
    rename_index :author_names, 'author_name_idx', 'ix_author_names__name'

    rename_index :citations, 'index_authorships_on_reference_id', 'ix_citations__reference_id'

    rename_index :comments, 'index_comments_on_commentable_id_and_commentable_type',
      'ix_comments__commentable_id__commentable_type'
    rename_index :comments, 'index_comments_on_user_id', 'ix_comments__user_id'

    rename_index :feedbacks, 'index_feedbacks_on_user_id', 'ix_feedbacks__user_id'

    rename_index :history_items, 'ix_taxon_history_items__protonym_id', 'ix_history_items__protonym_id'
    rename_index :history_items, 'fk_history_items__object_taxon_id__taxa__id',
      'ix_history_items__object_taxon_id__taxa__id'

    rename_index :institutions, 'index_institutions_on_abbreviation', 'ux_institutions__abbreviation'

    rename_index :issues, 'index_issues_on_closer_id', 'ix_issues__closer_id'
    rename_index :issues, 'index_issues_on_user_id', 'ix_issues__user_id'

    rename_index :names, 'index_names_on_id_and_type', 'ix_names__id__type'
    rename_index :names, 'name_name_index', 'ix_names__name'

    rename_index :notifications, 'index_notifications_on_attached_type_and_attached_id',
      'ix_notifications__attached_type__attached_id'
    rename_index :notifications, 'index_notifications_on_notifier_id', 'ix_notifications__notifier_id'
    rename_index :notifications, 'index_notifications_on_user_id', 'ix_notifications__user_id'

    rename_index :protonyms, 'index_protonyms_on_authorship_id', 'ix_protonyms__authorship_id'
    rename_index :protonyms, 'protonyms_name_id_idx', 'ix_protonyms__name_id'
    rename_index :protonyms, 'index_protonyms_on_type_name_id', 'ux_protonyms__type_name_id'

    rename_index :publishers, 'publishers_name_idx', 'ix_publishers__name'

    rename_index :read_marks, 'read_marks_reader_readable_index', 'ix_x_read_marks__reader_readable_index'

    rename_index :reference_author_names, 'author_participations_author_id_idx',
      'ix_reference_author_names__author_name_id'
    rename_index :reference_author_names, 'author_participations_reference_id_position_idx',
      'ix_reference_author_names__reference_id__position'
    rename_index :reference_author_names, 'author_participations_reference_id_idx',
      'ix_reference_author_names__reference_id'

    rename_index :reference_documents, 'index_reference_documents_on_reference_id',
      'ux_reference_documents__reference_id'

    rename_index :reference_sections, 'index_reference_sections_on_taxon_id_and_position',
      'ix_reference_sections__taxon_id__position'

    rename_index :references, 'references_created_at_idx', 'ix_references__created_at'
    rename_index :references, 'index_references_on_id_and_type', 'ix_references__id__type'
    rename_index :references, 'references_journal_id_idx', 'ix_references__journal_id'
    rename_index :references, 'references_nested_reference_id_idx', 'ix_references__nesting_reference_id'

    rename_index :references, 'references_publisher_id_idx', 'ix_references__publisher_id'
    rename_index :references, 'references_updated_at_idx', 'ix_references__updated_at'

    rename_index :settings, 'index_settings_on_target_type_and_target_id_and_var',
      'ux_settings__target_type__target_id__var'
    rename_index :settings, 'index_settings_on_target_type_and_target_id',
      'ix_settings__target_type__target_id'

    rename_index :site_notices, 'index_site_notices_on_user_id', 'ix_site_notices__user_id'
  end
end
