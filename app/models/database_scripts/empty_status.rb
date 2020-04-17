# frozen_string_literal: true

module DatabaseScripts
  class EmptyStatus
    include Service

    NOT_APPLICABLE = 'N/A'

    attr_private_initialize :database_script

    def call
      empty_status
    end

    private

      def empty_status
        return database_script.empty_status if database_script.respond_to?(:empty_status)
        return '??' unless database_script.respond_to?(:results)
        return 'Excluded (slow/list)' if list? || slow?

        if database_script.results.any?
          'Not empty'
        else
          'Empty'
        end
      end

      def list?
        database_script.tags.include?('list') ||
          database_script.section == DatabaseScripts::Tagging::LIST_SECTION
      end

      def slow?
        database_script.decorate.slow?
      end
  end
end
