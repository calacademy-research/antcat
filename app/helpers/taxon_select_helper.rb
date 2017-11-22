module TaxonSelectHelper
  def taxon_select_tag taxon_attribute_name, taxon_id, rank: nil
    taxon = Taxon.find_by(id: taxon_id)
    taxon_id = taxon.try(:id)

    select_tag taxon_attribute_name,
      options_for_select([taxon_id].compact, taxon_id),
      class: 'select2-autocomplete', data: data_attributes(taxon, rank)
  end

  private
    def data_attributes taxon, rank
      for_taxon = if taxon
                    {
                      name_html: taxon.name.name_html,
                      name_with_fossil: taxon.name_with_fossil,
                      author_citation: taxon.author_citation,
                    }
                  end

      { taxon_select: true, rank: rank }.merge(for_taxon || {})
    end

  module FormBuilderAdditions
    include ActionView::Helpers::FormOptionsHelper
    include TaxonSelectHelper

    def taxon_select taxon_attribute_name, rank: nil
      taxon = object.send taxon_attribute_name
      taxon_id = taxon.try(:id)

      self.select "#{taxon_attribute_name}_id".to_sym,
        options_for_select([taxon_id].compact, taxon_id),
        { include_blank: '(none)' },
        class: 'select2-autocomplete', data: data_attributes(taxon, rank)
    end
  end
end

ActionView::Helpers::FormBuilder.send(:include, TaxonSelectHelper::FormBuilderAdditions)
