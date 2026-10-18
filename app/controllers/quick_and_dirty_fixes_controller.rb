# frozen_string_literal: true

# NOTE: This is for quickly clearing issues (mostly from database scripts).
# Any action here is supposed to be temporary. There are no other rules. Consider it the Wild West.

# :nocov:
class QuickAndDirtyFixesController < ApplicationController
  before_action :ensure_user_is_at_least_helper
  # Same roles as the regular actions: deleting history items and editing taxa are editor-only.
  before_action :ensure_user_is_editor, only: [:delete_history_item, :flag_as_original_combination, :update_current_taxon_id]

  def convert_to_taxac_tags
    history_item = HistoryItem.find(params.expect(:history_item_id))

    old_taxt = history_item.taxt
    new_taxt = QuickAndDirtyFixes::ConvertTaxToTaxacTags[old_taxt]

    if old_taxt == new_taxt
      notify_error "Converted to taxac tags, but nothing was changed"
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity Activity::UPDATE, current_user, edit_summary: "[automatic] Converted to taxac tags"
      notify_success "Converted to taxac tags: '%s'", new_taxt
    else
      notify_error "Could not convert to taxac tags"
    end
  end

  def delete_history_item
    history_item = HistoryItem.find(params.expect(:history_item_id))
    edit_summary = params[:edit_summary]

    if history_item.destroy
      history_item.create_activity Activity::DESTROY, current_user, edit_summary: "[semi-automatic] #{edit_summary}"
      notify_success "Deleted history item"
    else
      notify_error "Could not delete history item"
    end
  end

  # TODO: Remove after clearing `ProtonymsWithoutAnOriginalCombination`.
  def flag_as_original_combination
    taxon = Taxon.find(params.expect(:taxon_id))

    if taxon.original_combination?
      notify_error "Taxon's is already flagged as 'original_combination'"
    elsif taxon.protonym.original_combination
      notify_error "Taxon's protonym already has an original_combination"
    elsif taxon.update(original_combination: true)
      taxon.create_activity Activity::UPDATE, current_user, edit_summary: "[semi-automatic] Flag as `original_combination`"
      notify_success "Flagged as 'original_combination'"
    else
      notify_error "Could not update 'original_combination'"
    end
  end

  def force_remove_pages_from_taxac_tags
    history_item = HistoryItem.find(params.expect(:history_item_id))

    old_taxt = history_item.taxt
    new_taxt = QuickAndDirtyFixes::ForceRemovePagesFromTaxacTags[old_taxt]

    if old_taxt == new_taxt
      notify_error "Could not force-remove pages from taxac tags, nothing was changed"
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity Activity::UPDATE, current_user, edit_summary: "[automatic] Force-remove page numbers from taxac tags"
      notify_success "Force-removed pages from taxac tags: '%s'", new_taxt
    else
      notify_error "Could not force-remove pages from taxac tags"
    end
  end

  def remove_pages_from_taxac_tags
    history_item = HistoryItem.find(params.expect(:history_item_id))

    old_taxt = history_item.taxt
    new_taxt = QuickAndDirtyFixes::RemovePagesFromTaxacTags[old_taxt]

    if old_taxt == new_taxt
      notify_error "Could not remove pages from taxac tags, nothing was changed"
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity Activity::UPDATE, current_user, edit_summary: "[automatic] Remove page numbers from taxac tags"
      notify_success "Removed pages from taxac tags: '%s'", new_taxt
    else
      notify_error "Could not remove pages from taxac tags"
    end
  end

  def replace_missing_tags
    history_item = HistoryItem.find(params.expect(:history_item_id))

    old_taxt = history_item.taxt
    new_taxt = QuickAndDirtyFixes::ReplaceMissingTags[old_taxt]

    if old_taxt == new_taxt
      notify_error "Replaced missing tags, but nothing was changed"
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity Activity::UPDATE, current_user, edit_summary: "[automatic] Replaced `missing` tags"
      notify_success "Replaced missing tags: '%s'", new_taxt
    else
      notify_error "Could not replace missing tags"
    end
  end

  def strip_except_replacement_name_for
    history_item = HistoryItem.find(params.expect(:history_item_id))
    edit_summary = params[:edit_summary]

    old_taxt = history_item.taxt
    new_taxt = old_taxt[/^Replacement name for {\w+ [0-9]+}/]

    if new_taxt.blank?
      notify_error "Could not strip item (blank taxt?)"
    elsif old_taxt == new_taxt
      notify_error "Stripped item, but nothing was changed"
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity Activity::UPDATE, current_user,
        edit_summary: "[automatic] Strip except 'Replacement name for TAG ID' (#{edit_summary})"
      notify_success "Stripped to: '%s'", new_taxt
    else
      notify_error "Could not strip item"
    end
  end

  def update_current_taxon_id
    taxon = Taxon.find(params.expect(:taxon_id))
    new_current_taxon = Taxon.find(params.expect(:new_current_taxon_id))

    if taxon.current_taxon == new_current_taxon
      notify_error "Updated current_taxon_id, but nothing was changed"
    elsif taxon.update(current_taxon_id: new_current_taxon.id)
      taxon.create_activity Activity::UPDATE, current_user, edit_summary: "[automatic] Update `current_taxon_id`"
      notify_success "Updated current_taxon_id"
    else
      notify_error "Could not update current_taxon_id"
    end
  end

  private

    # Responses are evaluated as JavaScript by rails-ujs and the notification shows its message as HTML,
    # so data (e.g. a history item's taxt) is HTML-escaped and then JSON-encoded, never interpolated.
    def notify_success message, *data
      render js: "AntCat.notifySuccess(#{notification_message(message, data)});"
    end

    def notify_error message, *data
      render js: "AntCat.notifyError(#{notification_message(message, data)});"
    end

    def notification_message message, data
      escaped = data.map { |value| ERB::Util.html_escape(value.to_s).to_str }
      ActiveSupport::JSON.encode(format(message, *escaped))
    end
end
# :nocov:
