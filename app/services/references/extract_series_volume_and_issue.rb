module References
  class ExtractSeriesVolumeAndIssue
    include Service

    def initialize string
      @string = string
    end

    def call
      series_volume_and_issue_parts
    end

    private

      attr_reader :string

      def series_volume_and_issue_parts
        parts = {}
        return parts unless string

        matches = string.match(/(\(\w+\))?(\w+)(\(\w+\))?/)
        return parts unless matches

        parts[:series] = matches[1].match(/\((\w+)\)/)[1] if matches[1].present?
        parts[:volume] = matches[2]
        parts[:issue] = matches[3].match(/\((\w+)\)/)[1] if matches[3].present?
        parts
      end
  end
end
