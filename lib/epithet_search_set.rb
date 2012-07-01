class EpithetSearchSet

  attr_reader :epithets

  def initialize epithet
    epithets = [epithet]
    epithets = frequent_misspellings epithets
    epithets = declensions epithets
    epithets = orthographic epithets
    epithets = deemed_identical epithets
    @epithets = epithets.uniq
  end

  def frequent_misspellings epithets
    epithets.concat(epithets.inject([]) do |epithets, epithet|
      epithets << 'alfari' if epithet == 'alfaroi'
      epithets << epithet.gsub(/^columbic/, 'colombic') if epithet =~ /^columbic/
      epithets
    end).uniq
  end

  def declensions epithets
    epithets.concat(epithets.inject([]) do |epithets, epithet|
      epithets << epithet
      epithets.concat first_declension_nominative_singular epithet
      epithets.concat first_declension_genitive_singular epithet
      epithets.concat third_declension_nominative_singular epithet
      epithets
    end).uniq
  end

  def first_declension_nominative_singular epithet
    decline epithet, "(?:[#{CONSONANTS}][ei]?|qu)", ['us', 'a', 'um']
  end

  def first_declension_genitive_singular epithet
    decline epithet, "[#{CONSONANTS}]i?", ['i', 'ae']
  end

  def third_declension_nominative_singular epithet
    decline epithet, "[#{CONSONANTS}]", ['e', 'is']
  end

  def decline epithet, stem, endings
    endings_regexp = '(' + endings.join('|') + ')'
    return [] unless epithet =~ /#{stem}#{endings_regexp}$/
    endings.map {|ending| epithet.gsub(/(#{stem})#{endings_regexp}$/, "\\1#{ending}")}
  end

  def orthographic epithets
    epithets = ae_and_e epithets
    epithets.concat p_and_ph epithets
    epithets.uniq
  end

  def ae_and_e epithets
    epithets.concat(epithets.inject([]) do |epithets, epithet|
      consonants = "(?:[#{CONSONANTS}][ei]?|qu)"
      epithets << epithet.gsub(/(#{consonants})e(#{consonants})/) do |string|
        if ['ter', 'del'].include?(string)
          string
        else
          $1 + 'ae' + $2
        end
      end
      epithets << epithet.gsub(/(#{consonants})ae(#{consonants})/) do |string|
        $1 + 'e' + $2
      end
      epithets
    end).uniq
  end

  def p_and_ph epithets
    epithets.concat(epithets.inject([]) do |epithets, epithet|
      epithets << epithet.gsub(/ph/, 'p')
      epithets << epithet.gsub(/p([^h])/, 'ph\1')
      epithets
    end).uniq
  end

  def deemed_identical epithets
    lll('start'){%q{epithets}}
    v = epithets.concat(epithets.inject([]) do |epithets, epithet|
      if ends_with epithet, 'i'
        epithets << replace_ending(epithet, 'i', 'ii')
      elsif ends_with epithet, 'ii'
        epithets << replace_ending(epithet, 'ii', 'i')
      end
      epithets
    end).uniq
    lll('end'){%q{epithets}}
  end

  def ends_with epithet, ending
    epithet =~ /[#{CONSONANTS}]#{ending}$/
  end

  def replace_ending epithet, old_ending, new_ending
    epithet.gsub /([#{CONSONANTS}])#{old_ending}$/, "\\1#{new_ending}"
  end

  def replace_stem epithet, new_stem, stem = "[#{CONSONANTS}]"
    epithet.gsub /^#{stem}/, new_stem
  end

  CONSONANTS = 'bcdfghjklmnprstvxyz'
end
