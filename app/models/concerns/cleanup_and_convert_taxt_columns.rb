# frozen_string_literal: true

module CleanupAndConvertTaxtColumns
  private

    def cleanup_and_convert_taxt_columns *taxt_columns
      taxt_columns.each do |taxt_column|
        new_taxt = public_send(taxt_column)
        new_taxt = Taxt::Cleanup[new_taxt]
        new_taxt = Taxt::ConvertTags[new_taxt]

        public_send(:"#{taxt_column}=", new_taxt)
      end
    end
end
