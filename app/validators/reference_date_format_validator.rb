# frozen_string_literal: true

class ReferenceDateFormatValidator < ActiveModel::EachValidator
  ERROR_MESSAGE = <<~STR.squish
    must match format YYYY, YYYYMM or YYYYMMDD (optionally separated by dashes; trailing question mark allowed)
  STR

  VALID_FORMAT_REGEX = /
    \A
      \d{4}        # Full year, YYYY.

      (            # Optional month and day.
        \d{4}|     # MMDD
        \d\d|      # MM
        -\d\d|     # -MM
        -\d\d-\d\d # -MM-DD
      )?
      \??          # Optional trailing question mark.
    \Z
  /x

  def validate_each record, attribute, value
    return if value.nil? || valid_format?(value)

    record.errors.add(attribute, options[:message] || ERROR_MESSAGE)
  end

  private

    def valid_format? value
      value.match?(VALID_FORMAT_REGEX)
    end
end
