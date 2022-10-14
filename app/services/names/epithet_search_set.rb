# frozen_string_literal: true

module Names
  class EpithetSearchSet
    include Service

    CONSONANTS = 'bcdfghjklmnprstvxyz' # NOTE: No 'q' or 'w', but includes 'y'.

    attr_private_initialize :epithet

    def call
      ([epithet] + frequent_misspellings + declensions + orthographic + deemed_identical).uniq
    end

    private

      def frequent_misspellings
        epithets = []
        epithets << 'alfari' if epithet == 'alfaroi'
        epithets << epithet.gsub(/^columbic/, 'colombic') if epithet.start_with?('columbic')
        epithets
      end

      ####################

      def declensions
        first_declension_nominative_singular +
          first_declension_genitive_singular +
          first_and_second_declension_adjectives_in_er_nominative_singular +
          third_declension_nominative_singular
      end

      def first_declension_nominative_singular
        decline "(?:[#{CONSONANTS}][ei]?|qu)", ['us', 'a', 'um']
      end

      def first_declension_genitive_singular
        decline "[#{CONSONANTS}]i?", ['i', 'ae']
      end

      def first_and_second_declension_adjectives_in_er_nominative_singular
        decline "[#{CONSONANTS}]", ['er', 'era', 'erum']
      end

      def third_declension_nominative_singular
        decline "[#{CONSONANTS}]", ['e', 'is']
      end

      def decline stem, endings
        endings_regexp = '(' + endings.join('|') + ')'
        return [] unless /#{stem}#{endings_regexp}$/.match?(epithet)

        endings.map { |ending| epithet.gsub(/(#{stem})#{endings_regexp}$/, "\\1#{ending}") }
      end

      ####################

      def orthographic
        ae_and_e + p_and_ph + v_and_w
      end

      def ae_and_e
        epithets = []
        consonants = "(?:[#{CONSONANTS}][ei]?|qu)"

        epithets << epithet.gsub(/(#{consonants})e(#{consonants})/) do |string|
          if ['ter', 'del'].include? string
            string
          else
            Regexp.last_match(1) + 'ae' + Regexp.last_match(2)
          end
        end

        epithets << epithet.gsub(/(#{consonants})ae(#{consonants})/) do |_string|
          Regexp.last_match(1) + 'e' + Regexp.last_match(2)
        end

        epithets
      end

      def p_and_ph
        epithets = []
        epithets << epithet.gsub(/ph/, 'p')
        epithets << epithet.gsub(/p([^h])/, 'ph\1')
        epithets
      end

      def v_and_w
        epithets = []
        epithets << epithet.tr('v', 'w')
        epithets << epithet.tr('w', 'v')
        epithets
      end

      ####################

      def deemed_identical
        epithets = []

        if ends_with?(epithet, 'i')
          epithets << replace_ending(epithet, 'i', 'ii')
        elsif ends_with?(epithet, 'ii')
          epithets << replace_ending(epithet, 'ii', 'i')
        end

        epithets
      end

      def ends_with? epithet, ending
        epithet =~ /[#{CONSONANTS}]#{ending}$/
      end

      def replace_ending epithet, old_ending, new_ending
        epithet.gsub(/([#{CONSONANTS}])#{old_ending}$/, "\\1#{new_ending}")
      end
  end
end
