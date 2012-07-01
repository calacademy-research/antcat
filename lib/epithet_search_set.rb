class EpithetSearchSet

  attr_reader :epithets

  def initialize epithet
    @epithets = [epithet]
    frequent_misspellings(epithet)
    first_declension_nominative_singular(epithet)
    first_declension_genitive_singular(epithet)
    third_declension_nominative_singular(epithet)
    make_deemed_identical_set(epithet)

    more_epithets = epithets.inject([]) do |epithets, epithet|
      consonants = '(?:[bcdfghjklmnprstvxyz][ei]?|qu)'
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
    end
    epithets.concat more_epithets

    more_epithets = epithets.inject([]) do |epithets, epithet|
      epithets << epithet.gsub(/ph/, 'p')
      epithets << epithet.gsub(/p([^h])/, 'ph\1')
    end
    epithets.concat more_epithets

    @epithets = epithets.uniq
  end

  def frequent_misspellings epithet
    @epithets.concat epithet == 'alfaroi' ? ['alfari'] : []
  end

  def decline epithet, stem, endings
    endings_regexp = '(' + endings.join('|') + ')'
    return unless epithet =~ /#{stem}#{endings_regexp}$/
    for ending in endings
      @epithets << epithet.gsub(/(#{stem})#{endings_regexp}$/, "\\1#{ending}")
    end
  end

  def first_declension_nominative_singular epithet
    decline epithet, '(?:[bcdfghjklmnprstvxyz][ei]?|qu)', ['us', 'a', 'um']
  end

  def first_declension_genitive_singular epithet
    decline epithet, '[bcdfghjklmnprstvxyz]i?', ['i', 'ae']
  end

  def third_declension_nominative_singular epithet
    decline epithet, '[bcdfghjklmnprstvxyz]', ['e', 'is']
  end

  def make_deemed_identical_set epithet
    if has_ending epithet, 'i'
      @epithets << replace_ending(epithet, 'i', 'ii')
    elsif has_ending epithet, 'ii'
      @epithets << replace_ending(epithet, 'ii', 'i')
    end
  end

  def has_ending epithet, ending, stem = '[bcdfghjklmnprstvxyz]'
    epithet =~ /#{stem}#{ending}$/
  end

  def replace_ending epithet, old_ending, new_ending, stem = '[bcdfghjklmnprstvxyz]'
    epithet.gsub /(#{stem})#{old_ending}$/, "\\1#{new_ending}"
  end

end
