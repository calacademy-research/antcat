# frozen_string_literal: true

module RecordPickerHelper
  def taxon_picker taxon, name:, id: nil, ranks: nil
    render PickerComponent.new(:taxon, taxon, name: name, id: id, ranks: ranks)
  end

  def protonym_picker protonym, name:, id: nil
    render PickerComponent.new(:protonym, protonym, name: name, id: id)
  end

  def reference_picker reference, name:, id: nil
    render PickerComponent.new(:reference, reference, name: name, id: id)
  end
end
