# frozen_string_literal: true

module DatabaseScripts
  class EmptyStatus
    include Service

    attr_private_initialize :database_script

    def call
      empty_status
    end

    private

      def empty_status
        return '??' unless database_script.respond_to?(:results)
        return 'Excluded (slow/list)' if list_or_slow?

        if database_script.results.any?
          'Not empty'
        else
          'Empty'
        end
      end

      def list_or_slow?
        database_script.tags.include?('list') ||
          database_script.section == DatabaseScripts::Tagging::LIST_SECTION ||
          database_script.decorate.slow?
      end
  end
end
