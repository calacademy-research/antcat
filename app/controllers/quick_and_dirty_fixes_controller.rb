# frozen_string_literal: true

# NOTE: This is for quickly clearing issues (mostly from database scripts).
# Any action here is supposed to be temporary. There are no other rules. Consider it the Wild West.

# :nocov:
class QuickAndDirtyFixesController < ApplicationController
  before_action :ensure_user_is_at_least_helper

  def convert_to_taxac_tags
    history_item = HistoryItem.find(params[:history_item_id])

    old_taxt = history_item.taxt
    new_taxt = QuickAndDirtyFixes::ConvertTaxToTaxacTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Converted to taxac tags, but nothing was changed"))
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity Activity::UPDATE, current_user, edit_summary: "[automatic] Converted to taxac tags"
      render js: %(AntCat.notifySuccess("Converted to taxac tags: '#{new_taxt}'"))
    else
      render js: %(AntCat.notifyError("Could not convert to taxac tags"))
    end
  end

  def delete_history_item
    history_item = HistoryItem.find(params[:history_item_id])
    edit_summary = params[:edit_summary]

    if history_item.destroy
      history_item.create_activity Activity::DESTROY, current_user, edit_summary: "[semi-automatic] #{edit_summary}"
      render js: %(AntCat.notifySuccess("Deleted history item"))
    else
      render js: %(AntCat.notifyError("Could not delete history item"))
    end
  end

  # TODO: Remove after clearing `ProtonymsWithoutAnOriginalCombination`.
  def flag_as_original_combination
    taxon = Taxon.find(params[:taxon_id])

    if taxon.original_combination?
      render js: %(AntCat.notifyError("Taxon's is already flagged as 'original_combination'"))
    elsif taxon.protonym.original_combination
      render js: %(AntCat.notifyError("Taxon's protonym already has an original_combination"))
    elsif taxon.update(original_combination: true)
      taxon.create_activity Activity::UPDATE, current_user, edit_summary: "[semi-automatic] Flag as `original_combination`"
      render js: %(AntCat.notifySuccess("Flagged as 'original_combination'"))
    else
      render js: %(AntCat.notifyError("Could not update 'original_combination'"))
    end
  end

  def force_remove_pages_from_taxac_tags
    history_item = HistoryItem.find(params[:history_item_id])

    old_taxt = history_item.taxt
    new_taxt = QuickAndDirtyFixes::ForceRemovePagesFromTaxacTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Could not force-remove pages from taxac tags, nothing was changed"))
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity Activity::UPDATE, current_user, edit_summary: "[automatic] Force-remove page numbers from taxac tags"
      render js: %(AntCat.notifySuccess("Force-removed pages from taxac tags: '#{new_taxt}'"))
    else
      render js: %(AntCat.notifyError("Could not force-remove pages from taxac tags"))
    end
  end

  def remove_pages_from_taxac_tags
    history_item = HistoryItem.find(params[:history_item_id])

    old_taxt = history_item.taxt
    new_taxt = QuickAndDirtyFixes::RemovePagesFromTaxacTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Could not remove pages from taxac tags, nothing was changed"))
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity Activity::UPDATE, current_user, edit_summary: "[automatic] Remove page numbers from taxac tags"
      render js: %(AntCat.notifySuccess("Removed pages from taxac tags: '#{new_taxt}'"))
    else
      render js: %(AntCat.notifyError("Could not remove pages from taxac tags"))
    end
  end

  def replace_missing_tags
    history_item = HistoryItem.find(params[:history_item_id])

    old_taxt = history_item.taxt
    new_taxt = QuickAndDirtyFixes::ReplaceMissingTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Replaced missing tags, but nothing was changed"))
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity Activity::UPDATE, current_user, edit_summary: "[automatic] Replaced `missing` tags"
      render js: %(AntCat.notifySuccess("Replaced missing tags: '#{new_taxt}'"))
    else
      render js: %(AntCat.notifyError("Could not replace missing tags"))
    end
  end

  def strip_except_replacement_name_for
    history_item = HistoryItem.find(params[:history_item_id])
    edit_summary = params[:edit_summary]

    old_taxt = history_item.taxt
    new_taxt = old_taxt[/^Replacement name for {\w+ [0-9]+}/]

    if new_taxt.blank?
      render js: %(AntCat.notifyError("Could not strip item (blank taxt?)"))
    elsif old_taxt == new_taxt
      render js: %(AntCat.notifyError("Stripped item, but nothing was changed"))
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity Activity::UPDATE, current_user,
        edit_summary: "[automatic] Strip except 'Replacement name for TAG ID' (#{edit_summary})"
      render js: %(AntCat.notifySuccess("Stripped to: '#{new_taxt}'"))
    else
      render js: %(AntCat.notifyError("Could not strip item"))
    end
  end

  def update_current_taxon_id
    taxon = Taxon.find(params[:taxon_id])
    new_current_taxon = Taxon.find(params[:new_current_taxon_id])

    if taxon.current_taxon == new_current_taxon
      render js: %(AntCat.notifyError("Updated current_taxon_id, but nothing was changed"))
    elsif taxon.update(current_taxon_id: new_current_taxon.id)
      taxon.create_activity Activity::UPDATE, current_user, edit_summary: "[automatic] Update `current_taxon_id`"
      render js: %(AntCat.notifySuccess("Updated current_taxon_id"))
    else
      render js: %(AntCat.notifyError("Could not update current_taxon_id"))
    end
  end
end
# :nocov:
