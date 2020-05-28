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
      render js: %(AntCat.notifyError("Could convert Bolton tags"))
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

  def convert_to_taxac_tags
    taxon_history_item = TaxonHistoryItem.find(params[:taxon_history_item_id])

    old_taxt = taxon_history_item.taxt
    new_taxt = convert_taxt_to_taxac_tags(old_taxt)

    if old_taxt == new_taxt
      render js: %(AntCat.notifyError("Converted to taxac tags, but nothing was changed"))
    elsif taxon_history_item.update(taxt: new_taxt)
      taxon_history_item.create_activity :update, current_user, edit_summary: "[automatic] Converted to taxac tags"
      render js: %(AntCat.notifySuccess("Converted to taxac tags: '#{new_taxt}'", false))
    else
      render js: %(AntCat.notifyError("Could convert to taxac tags"))
    end
  end

  private

    # Copy-pasted from `HistoryItemsWithRefTagsAsAuthorCitations`.
    def convert_taxt_to_taxac_tags taxt
      ids = taxt.scan(/{tax (?<tax_id>[0-9]+)} {ref (?<ref_id>[0-9]+)}:( [0-9]+)?/)

      string = taxt.dup

      ids.each do |(tax_id, ref_id)|
        taxon = Taxon.find(tax_id)
        reference = Reference.find(ref_id)

        if taxon.authorship_reference == reference
          string.gsub!(
            /\{tax #{tax_id}\} \{ref #{ref_id}\}:( [0-9]+)?/,
            "{taxac #{tax_id}}"
          )
        else
          raise 'not OK'
        end
      end

      string
    end
end
# :nocov:
