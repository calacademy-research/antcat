# frozen_string_literal: true

module RecordPickerHelper
  def taxon_picker taxon, name:, id: nil, ranks: nil
    render PickerComponent.new(:taxon, taxon, name: name, id: id, ranks: ranks)
  end

  def protonym_picker protonym, name:, id: nil, allow_clear: true
    render PickerComponent.new(:protonym, protonym, name: name, id: id, allow_clear: allow_clear)
  end

  def reference_picker reference, name:, id: nil, allow_clear: true
    render PickerComponent.new(:reference, reference, name: name, id: id, allow_clear: allow_clear)
  end
end
