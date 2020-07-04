# frozen_string_literal: true

# NOTE: This is for quickly clearing issues (mostly from database scripts).
# Any action here is supposed to be temporary. There are no other rules. Consider it the Wild West.

# :nocov:
class QuickAndDirtyFixesController < ApplicationController
  before_action :ensure_user_is_at_least_helper

  def convert_bolton_tags
    taxon_history_item = TaxonHistoryItem.find(params[:taxon_history_item_id])

    old_taxt = taxon_history_item.taxt
    new_taxt = Markdowns::BoltonKeysToRefTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Converted Bolton tags, but nothing was changed"))
    elsif taxon_history_item.update(taxt: new_taxt)
      taxon_history_item.create_activity :update, current_user, edit_summary: "[automatic] Converted Bolton tags"
      render js: %(AntCat.notifySuccess("Converted Bolton tags to: '#{new_taxt}'", false))
    else
      render js: %(AntCat.notifyError("Could not convert Bolton tags"))
    end
  end

  def convert_to_taxac_tags
    taxon_history_item = TaxonHistoryItem.find(params[:taxon_history_item_id])

    old_taxt = taxon_history_item.taxt
    new_taxt = QuickAndDirtyFixes::ConvertTaxToTaxacTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Converted to taxac tags, but nothing was changed"))
    elsif taxon_history_item.update(taxt: new_taxt)
      taxon_history_item.create_activity :update, current_user, edit_summary: "[automatic] Converted to taxac tags"
      render js: %(AntCat.notifySuccess("Converted to taxac tags: '#{new_taxt}'", false))
    else
      render js: %(AntCat.notifyError("Could not convert to taxac tags"))
    end
  end

  def force_remove_pages_from_taxac_tags
    taxon_history_item = TaxonHistoryItem.find(params[:taxon_history_item_id])

    old_taxt = taxon_history_item.taxt
    new_taxt = QuickAndDirtyFixes::ForceRemovePagesFromTaxacTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Could not force-remove pages from taxac tags, nothing was changed"))
    elsif taxon_history_item.update(taxt: new_taxt)
      taxon_history_item.create_activity :update, current_user, edit_summary: "[automatic] Force-remove page numbers from taxac tags"
      render js: %(AntCat.notifySuccess("Force-removed pages from taxac tags: '#{new_taxt}'", false))
    else
      render js: %(AntCat.notifyError("Could not force-remove pages from taxac tags"))
    end
  end

  def remove_pages_from_taxac_tags
    taxon_history_item = TaxonHistoryItem.find(params[:taxon_history_item_id])

    old_taxt = taxon_history_item.taxt
    new_taxt = QuickAndDirtyFixes::RemovePagesFromTaxacTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Could not remove pages from taxac tags, nothing was changed"))
    elsif taxon_history_item.update(taxt: new_taxt)
      taxon_history_item.create_activity :update, current_user, edit_summary: "[automatic] Remove page numbers from taxac tags"
      render js: %(AntCat.notifySuccess("Removed pages from taxac tags: '#{new_taxt}'", false))
    else
      render js: %(AntCat.notifyError("Could not remove pages from taxac tags"))
    end
  end

  def replace_missing_tags
    taxon_history_item = TaxonHistoryItem.find(params[:taxon_history_item_id])

    old_taxt = taxon_history_item.taxt
    new_taxt = QuickAndDirtyFixes::ReplaceMissingTags[old_taxt]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Replaced missing tags, but nothing was changed"))
    elsif taxon_history_item.update(taxt: new_taxt)
      taxon_history_item.create_activity :update, current_user, edit_summary: "[automatic] Replaced `missing` tags"
      render js: %(AntCat.notifySuccess("Replaced missing tags: '#{new_taxt}'", false))
    else
      render js: %(AntCat.notifyError("Could not replace missing tags"))
    end
  end

  def replace_with_pro_tags
    taxon_history_item = TaxonHistoryItem.find(params[:taxon_history_item_id])

    old_taxt = taxon_history_item.taxt
    new_taxt = QuickAndDirtyFixes::HardcodedNameToProTag[taxon_history_item]

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Replaced with pro tags, but nothing was changed"))
    elsif taxon_history_item.update(taxt: new_taxt)
      taxon_history_item.create_activity :update, current_user, edit_summary: "[automatic] Replaced hardcoded name with `pro` tag(s)"
      render js: %(AntCat.notifySuccess("Replaced with pro tags: '#{new_taxt}'", false))
    else
      render js: %(AntCat.notifyError("Could not replace with pro tags"))
    end
  end
end
# :nocov:
