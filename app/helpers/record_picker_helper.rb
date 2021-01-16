# frozen_string_literal: true

module RecordPickerHelper
  PICKABLE_TYPES = [
    TAXA_PICKABLE_TYPE = 'taxa',
    PROTONYMS_PICKABLE_TYPE = 'protonyms',
    REFERENCES_PICKABLE_TYPE = 'references'
  ]

  def taxon_picker taxon, name:, id: nil, ranks: nil
    initial_item = taxon_picker_initial_item(taxon)

    record_picker(
      taxon&.id,
      TAXA_PICKABLE_TYPE,
      initial_item,
      name: name, id: id, ranks: ranks
    )
  end

  def protonym_picker protonym, name:, id: nil
    initial_item = protonym_picker_initial_item(protonym)

    record_picker(
      protonym&.id,
      PROTONYMS_PICKABLE_TYPE,
      initial_item,
      name: name, id: id
    )
  end

  def reference_picker reference, name:, id: nil
    initial_item = reference_picker_initial_item(reference)

    record_picker(
      reference&.id,
      REFERENCES_PICKABLE_TYPE,
      initial_item,
      name: name, id: id
    )
  end

  private

    def record_picker record_id, pickable_type, initial_item, name:, id: nil, ranks: nil
      initial_item_html = %(:initial-item="#{CGI.escapeHTML(initial_item)}") if initial_item
      pickable_ranks_html = %(:pickable-ranks="[#{Array.wrap(ranks).map { |r| "'#{r}'" }.join(', ')}]") if ranks

      picker_id = "#{name}__#{SecureRandom.uuid}"

      vue_component = <<~HTML.squish.html_safe
        <record-picker
          picker-id="#{picker_id}"
          pickable-type="#{pickable_type}"
          #{pickable_ranks_html}
          #{initial_item_html}>
        </record-picker>
      HTML

      tag.span do
        tag.input(value: record_id, name: name, id: id || name, data: { picker_id: picker_id }) + vue_component
      end
    end

    def taxon_picker_initial_item taxon
      return unless taxon
      Autocomplete::TaxonSerializer.new(taxon).to_json
    end

    def protonym_picker_initial_item protonym
      return unless protonym
      Autocomplete::ProtonymSerializer.new(protonym).to_json
    end

    def reference_picker_initial_item reference
      return unless reference
      Autocomplete::ReferenceSerializer.new(reference).to_json
    end
end
