# NOTE: This is for quickly clearing issues (mostly from database scripts).
# Any action here is supposed to be temporary. There are no other rules. Consider it the Wild West.

class QuickAndDirtyFixesController < ApplicationController
  before_action :ensure_user_is_at_least_helper

  def clear_type_taxt
    taxon = Taxon.find(params[:taxon_id])

    old_type_taxt = taxon.type_taxt
    new_type_taxt = clean_type_taxt old_type_taxt

    if taxon.update(type_taxt: nil)
      taxon.create_activity :update, current_user,
        edit_summary: "[automatic] Set type_taxt to <br>'#{new_type_taxt}' <br>was: <br>'#{old_type_taxt}'"
      render js: %(AntCat.notifySuccess("Changed to: '#{new_type_taxt || '<blank>'}'"))
    else
      render js: %(AntCat.notifyError("Could not clear type_taxt"))
    end
  end

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

  private

    def clean_type_taxt type_taxt
      if type_taxt.include?(Protonym::BY_MONOTYPY)
        Protonym::BY_MONOTYPY
      elsif type_taxt.include?(Protonym::BY_ORIGINAL_DESIGNATION)
        Protonym::BY_ORIGINAL_DESIGNATION
      elsif type_taxt =~ /, by subsequent designation of {ref \d+}: \d+.?/
        type_taxt[/, by subsequent designation of {ref \d+}: \d+.?/]
      end
    end
end
