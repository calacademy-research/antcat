# frozen_string_literal: true

module References
  class FormatDate
    include Service

    attr_private_initialize :reference_date

    def call
      return unless reference_date
      return reference_date if reference_date.size < 4
      format_date
    end

    private

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
