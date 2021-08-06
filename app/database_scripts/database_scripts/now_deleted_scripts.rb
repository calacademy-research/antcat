# frozen_string_literal: true

module DatabaseScripts
  class NowDeletedScripts < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

    def results
      placeholder
    end

    def render
      as_table do |t|
        t.header 'Check', 'Ok?'
        t.rows do |check|
          [
            check[:title],
            (check[:ok?] ? 'Yes' : bold_warning('No'))
          ]
        end
      end
    end

    private

      def placeholder
        [
          {
            title: 'placeholder',
            ok?: true
          }
        ]
      end
  end
end

__END__

section: regression-test
tags: [grab-bag]

description: >

related_scripts:
  - GrabBagChecks
  - NowDeletedScripts
