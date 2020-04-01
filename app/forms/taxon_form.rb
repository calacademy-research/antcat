# frozen_string_literal: true

class TaxonForm
  attr_private_initialize :taxon, :params, [:taxon_name_string, :protonym_name_string]

  def save
    save_taxon
  end

  private

    def save_taxon
      taxon.name = Names::BuildNameFromString[taxon_name_string]

      if params[:protonym_id].present?
        params.delete :protonym_attributes
      elsif protonym_name_string
        taxon.protonym.name = Names::BuildNameFromString[protonym_name_string]
      end

      taxon.attributes = params
      taxon.save
    end
end
