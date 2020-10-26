# frozen_string_literal: true

# NOTE: This is for quickly clearing issues (mostly from database scripts).
# Any action here is supposed to be temporary. There are no other rules. Consider it the Wild West.

# :nocov:
class QuickAndDirtyFixesController < ApplicationController
  before_action :ensure_user_is_at_least_helper

  # TODO: Not used (after migrating to protonym history items, 12faa7ec1). Use or remove.
  def convert_bolton_tags
    history_item = HistoryItem.find(params[:taxon_history_item_id])

    old_taxt = history_item.taxt
    new_taxt = Markdowns::BoltonKeysToRefTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Converted Bolton tags, but nothing was changed"))
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity :update, current_user, edit_summary: "[automatic] Converted Bolton tags"
      render js: %(AntCat.notifySuccess("Converted Bolton tags to: '#{new_taxt}'"))
    else
      render js: %(AntCat.notifyError("Could not convert Bolton tags"))
    end
  end

  def convert_to_taxac_tags
    history_item = HistoryItem.find(params[:taxon_history_item_id])

    old_taxt = history_item.taxt
    new_taxt = QuickAndDirtyFixes::ConvertTaxToTaxacTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Converted to taxac tags, but nothing was changed"))
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity :update, current_user, edit_summary: "[automatic] Converted to taxac tags"
      render js: %(AntCat.notifySuccess("Converted to taxac tags: '#{new_taxt}'"))
    else
      render js: %(AntCat.notifyError("Could not convert to taxac tags"))
    end
  end

  def force_remove_pages_from_taxac_tags
    history_item = HistoryItem.find(params[:taxon_history_item_id])

    old_taxt = history_item.taxt
    new_taxt = QuickAndDirtyFixes::ForceRemovePagesFromTaxacTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Could not force-remove pages from taxac tags, nothing was changed"))
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity :update, current_user, edit_summary: "[automatic] Force-remove page numbers from taxac tags"
      render js: %(AntCat.notifySuccess("Force-removed pages from taxac tags: '#{new_taxt}'"))
    else
      render js: %(AntCat.notifyError("Could not force-remove pages from taxac tags"))
    end
  end

  def remove_pages_from_taxac_tags
    history_item = HistoryItem.find(params[:taxon_history_item_id])

    old_taxt = history_item.taxt
    new_taxt = QuickAndDirtyFixes::RemovePagesFromTaxacTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Could not remove pages from taxac tags, nothing was changed"))
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity :update, current_user, edit_summary: "[automatic] Remove page numbers from taxac tags"
      render js: %(AntCat.notifySuccess("Removed pages from taxac tags: '#{new_taxt}'"))
    else
      render js: %(AntCat.notifyError("Could not remove pages from taxac tags"))
    end
  end

  def replace_missing_tags
    history_item = HistoryItem.find(params[:taxon_history_item_id])

    old_taxt = history_item.taxt
    new_taxt = QuickAndDirtyFixes::ReplaceMissingTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Replaced missing tags, but nothing was changed"))
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity :update, current_user, edit_summary: "[automatic] Replaced `missing` tags"
      render js: %(AntCat.notifySuccess("Replaced missing tags: '#{new_taxt}'"))
    else
      render js: %(AntCat.notifyError("Could not replace missing tags"))
    end
  end

  # TODO: Not used (after migrating to protonym history items, 12faa7ec1). Use or remove.
  def replace_missing_tag_with_tax_tag
    history_item = HistoryItem.find(params[:taxon_history_item_id])
    hardcoded_missing_name = params[:hardcoded_missing_name]
    replace_with_taxon_id = params[:replace_with_taxon_id]

    old_taxt = history_item.taxt
    new_taxt = old_taxt.dup.sub(
      /\{missing[0-9]? #{hardcoded_missing_name}\}/,
      "{tax #{replace_with_taxon_id}}"
    )

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Replaced missing tags with selected tax, but nothing was changed"))
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity :update, current_user, edit_summary: "[automatic] Replaced `missing` tags with selected tax"
      render js: %(AntCat.notifySuccess("Replaced missing tags with selected tax: '#{new_taxt}'"))
    else
      render js: %(AntCat.notifyError("Could not replace missing tags with selected tax"))
    end
  end

  # TODO: Not used (after migrating to protonym history items, 12faa7ec1). Use or remove.
  def switch_tax_tag
    history_item = HistoryItem.find(params[:taxon_history_item_id])
    replace_taxon = Taxon.find(params[:replace_tax_id])
    new_taxon = Taxon.find(params[:new_tax_id])

    old_taxt = history_item.taxt
    new_taxt = old_taxt.dup.sub(
      "{tax #{replace_taxon.id}}",
      "{tax #{new_taxon.id}}"
    )

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Switched tax tags, but nothing was changed"))
    elsif history_item.update(taxt: new_taxt)
      history_item.create_activity :update, current_user, edit_summary: "[automatic] Switch `tax` tags"
      render js: %(AntCat.notifySuccess("Switched tax tags: '#{new_taxt}'"))
    else
      render js: %(AntCat.notifyError("Could not switch tax tags"))
    end
  end

  def update_current_taxon_id
    taxon = Taxon.find(params[:taxon_id])
    new_current_taxon = Taxon.find(params[:new_current_taxon_id])

    if taxon.current_taxon == new_current_taxon
      render js: %(AntCat.notifyError("Updated current_taxon_id, but nothing was changed"))
    elsif taxon.update(current_taxon_id: new_current_taxon.id)
      taxon.create_activity :update, current_user, edit_summary: "[automatic] Update `current_taxon_id`"
      render js: %(AntCat.notifySuccess("Updated current_taxon_id"))
    else
      render js: %(AntCat.notifyError("Could not update current_taxon_id"))
    end
  end
end
# :nocov:
