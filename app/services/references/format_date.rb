module References
  class FormatDate
    include Service

    def initialize reference_date
      @reference_date = reference_date
    end

    def call
      return unless reference_date
      return reference_date if reference_date.size < 4
      format_date
    end

    private

      attr_reader :reference_date

      # TODO: Store normalized value in the database?
      def format_date
        match = reference_date.match(/(.*?)(\d{4,8})(.*)/)
        prefix = match[1]
        digits = match[2]
        suffix = match[3]

        year  = digits[0...4]
        month = digits[4...6]
        day   = digits[6...8]

        date = year
        date << '-' + month if month.present?
        date << '-' + day if day.present?

        prefix + date + suffix
      end
  end
end
