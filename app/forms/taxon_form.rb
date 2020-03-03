class TaxonForm
  def initialize taxon, taxon_params, taxon_name_string: nil, protonym_name_string: nil
    @taxon = taxon
    @params = taxon_params
    @taxon_name_string = taxon_name_string
    @protonym_name_string = protonym_name_string
  end

  def save
    save_taxon
  end

  private

    attr_reader :taxon, :params, :taxon_name_string, :protonym_name_string

    def save_taxon
      if taxon_name_string
        taxon.name = Names::BuildNameFromString[taxon_name_string]
      end

      if params[:protonym_id].present?
        params.delete :protonym_attributes
      elsif protonym_name_string
        taxon.protonym.name = Names::BuildNameFromString[protonym_name_string]
      end

      taxon.attributes = params
      taxon.save!
    end
end
