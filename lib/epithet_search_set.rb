class EpithetSearchSet

  attr_reader :epithets

  def initialize epithet
    @epithet = epithet
    @epithets = [@epithet]

    frequent_misspellings
    first_declension_nominative_singular
    first_declension_genitive_singular
    third_declension_nominative_singular
    make_deemed_identical_set

    more_epithets = @epithets.inject([]) do |epithets, epithet|
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
    @epithets.concat more_epithets

    more_epithets = @epithets.inject([]) do |epithets, epithet|
      epithets << epithet.gsub(/ph/, 'p')
      epithets << epithet.gsub(/p([^h])/, 'ph\1')
    end
    @epithets.concat more_epithets

    @epithets = @epithets.uniq
  end

  def frequent_misspellings
    @epithets.concat @epithet == 'alfaroi' ? ['alfari'] : []
  end

  def decline stem, endings
    endings_regexp = '(' + endings.join('|') + ')'
    return unless @epithet =~ /#{stem}#{endings_regexp}$/
    for ending in endings
      @epithets << @epithet.gsub(/(#{stem})#{endings_regexp}$/, "\\1#{ending}")
    end
  end

  def first_declension_nominative_singular
    decline '(?:[bcdfghjklmnprstvxyz][ei]?|qu)', ['us', 'a', 'um']
  end

  def first_declension_genitive_singular
    decline '[bcdfghjklmnprstvxyz]i?', ['i', 'ae']
  end

  def third_declension_nominative_singular
    decline '[bcdfghjklmnprstvxyz]', ['e', 'is']
  end

  def make_deemed_identical_set
    if has_ending 'i'
      @epithets << replace_ending('i', 'ii')
    elsif has_ending 'ii'
      @epithets << replace_ending('ii', 'i')
    end
  end

  def has_ending ending, stem = '[bcdfghjklmnprstvxyz]'
    @epithet =~ /#{stem}#{ending}$/
  end

  def replace_ending old_ending, new_ending, stem = '[bcdfghjklmnprstvxyz]'
    @epithet.gsub /(#{stem})#{old_ending}$/, "\\1#{new_ending}"
  end

end
