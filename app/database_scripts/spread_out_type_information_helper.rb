module SpreadOutTypeInformationHelper
  def results
    Protonym.where(id: Taxon.where.not(column_name => nil).group(:protonym_id).having('COUNT(*) > 1').select(:protonym_id))
  end

  def render
    as_table do |t|
      t.header :protonym, :authorship, :taxa, :unique_field_contents, :not_identical?
      t.rows do |protonym|
        uniqe_fields = protonym.taxa.pluck(column_name).compact.uniq

        [
          link_to(protonym.decorate.format_name, protonym_path(protonym)),
          protonym.authorship.reference.decorate.expandable_reference,
          protonym.taxa.map { |taxon| taxon.decorate.link_to_taxon }.join('<br>'),
          uniqe_fields.map { |string| string.truncate(100) }.join('<br>'),
          (uniqe_fields.size == 1 ? '-' : 'Not identical')
        ]
      end
    end
  end
end
