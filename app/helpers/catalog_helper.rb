module CatalogHelper
  def show_full_statistics? taxon
    taxon.invalid? || params[:include_full_statistics].present?
  end
end
