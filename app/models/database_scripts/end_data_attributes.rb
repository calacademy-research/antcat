# frozen_string_literal: true

require Rails.root.join('lib/read_end_data')

module DatabaseScripts
  class EndDataAttributes
    def initialize script_path
      @script_path = script_path
    end

    def title
      end_data[:title]&.html_safe
    end

    def category
      end_data[:category] || ""
    end

    def tags
      end_data[:tags] || []
    end

    def issue_description
      end_data[:issue_description]
    end

    def description
      end_data[:description] || ""
    end

    def related_scripts
      (end_data[:related_scripts] || []).map do |class_name|
        DatabaseScript.safe_new_from_filename_without_extension class_name
      end
    end

    private

      # The scripts' description, tags, etc, are stored in `DATA`.
      def end_data
        @_end_data ||= ReadEndData.new(script_path).call
      end

      attr_reader :script_path
  end
end
