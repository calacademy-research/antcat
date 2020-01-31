# NOTE: This is for quickly clearing issues (mostly from database scripts).
# Any action here is supposed to be temporary. There are no other rules. Consider it the Wild West.

class QuickAndDirtyFixesController < ApplicationController
  before_action :ensure_user_is_at_least_helper

  def clear_type_taxt
    taxon = Taxon.find(params[:taxon_id])

    old_type_taxt = taxon.type_taxt
    new_type_taxt = clean_type_taxt old_type_taxt

    taxon.update!(type_taxt: nil)

    taxon.create_activity :update, current_user,
      edit_summary: "[automatic] Set type_taxt to <br>'#{new_type_taxt}' <br>was: <br>'#{old_type_taxt}'"
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
