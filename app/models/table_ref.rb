# rubocop:disable Style/RedundantSelf

# TODO: Decide what to do with this.
TableRef = Struct.new(:table, :field, :id) do
  def detax
    return "&ndash;".html_safe unless taxt?
    Detax[model.find(id).public_send(field)]
  end

  def taxt?
    Detax::TAXT_MODELS_AND_FIELDS.any? do |(_model, table, field)|
      self.table == table && self.field.to_s == field
    end
  end

  private

    def model
      Detax::TAXT_MODELS_AND_FIELDS.find do |(_model, table, _field)|
        self.table == table
      end.first
    end
end
# rubocop:enable Style/RedundantSelf
