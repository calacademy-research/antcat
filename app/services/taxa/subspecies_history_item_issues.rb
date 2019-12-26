# TODO: Horrible copy-pasta from `SubspeciesListInHistoryItem`.

module Taxa
  class SubspeciesHistoryItemIssues
    include Service

    def initialize taxon
      @history_item = taxon.subspecies_list_in_history_items.first
    end

    def call
      extracted_ids = extract_taxt_ids history_item

      ids_same = ids_same?(history_item, extracted_ids)
      additional = extract_additional(history_item)
      all_extracted_are_subspecies = all_extracted_are_subspecies?(extracted_ids)
      non_valid_statuses_of_extracted = Taxon.where.not(status: Status::VALID).where(id: extracted_ids).pluck(:status).presence

      convertable = ids_same && additional.blank? && all_extracted_are_subspecies && non_valid_statuses_of_extracted.blank?

      return if convertable

      result = []
      result << '<span class="bold-warning">History item and valid subspecies in the database do not agree</span>'
      result << "Valid subspecies IDs from the database: #{valid_subspecies_ids(history_item)}"
      result << "Extracted IDs: #{extracted_ids}"

      unless ids_same
        result << 'Extracted IDs and IDs from database do not match'
      end

      unless all_extracted_are_subspecies
        result << 'All extracted IDs are not subspecies'
      end

      if additional.present?
        result << "Item has additional content after cleanup: #{Detax[additional]}"
      end

      if non_valid_statuses_of_extracted
        result << "Not all extracted subspecies are valid (other statuses: #{non_valid_statuses_of_extracted.join(', ')})"
      end

      result
    end

    private

      attr_reader :history_item

      def extract_additional history_item
        cleaned = history_item.taxt
        cleaned = cleaned.gsub(/Current subspecies: nominal plus /, '')

        valid_subspecies_ids(history_item).each do |id|
          cleaned = cleaned.gsub(/\{tax #{id}\}/, '')
        end

        cleaned = cleaned.gsub(', ', '')
        cleaned
      end

      def ids_same? history_item, extracted_ids
        valid_subspecies_ids(history_item) == extracted_ids
      end

      def valid_subspecies_ids history_item
        history_item.taxon.subspecies.valid.pluck(:id).sort
      end

      def extract_taxt_ids history_item
        history_item.taxt.scan(/\{tax (\d+)\}/).flatten.map(&:to_i).sort
      end

      def all_extracted_are_subspecies? extracted_ids
        Subspecies.where(id: extracted_ids).count == extracted_ids.size
      end
  end
end