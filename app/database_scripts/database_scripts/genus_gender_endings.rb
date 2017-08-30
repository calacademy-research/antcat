module DatabaseScripts
  class GenusGenderEndings < DatabaseScript
    def formatted_statistics
      output = "### Statistics\n"
      output << "-ending: already gendered / matches (incorrectly gendered)\n"
      endings.each do |gender, gender_endings|
        output << "##### #{gender}\n"
        gender_endings.each do |ending|
          all = Genus.where("name_cache REGEXP ?", "#{ending}$")
          already_gendered = all.joins(:name).where("names.gender IS NOT NULL").count
          incorrectly_gendered = all.joins(:name).where("names.gender != ?", gender).count
          output << "* -#{ending}: #{already_gendered}/#{all.count} (#{incorrectly_gendered})\n"
        end
        output << "\n<hr>\n"
      end
      output
    end

    def matches
      output = {}
      endings.each do |gender, gender_endings|
        output[gender] = {
          not_gendered: [],
          incorrectly_gendered: [],
          correctly_gendered: []
        }
        gender_endings.each do |ending|
          all = Genus.where("name_cache REGEXP ?", "#{ending}$").joins(:name)
          output[gender][:not_gendered].concat all.where("names.gender IS NULL")
          output[gender][:incorrectly_gendered].concat all.where("names.gender != ?", gender)
          output[gender][:correctly_gendered].concat all.where("names.gender = ?", gender)
        end
      end

      sort_results output
    end

    def formatted_matches
      string = "\n### Matches"
      matches.each do |gender, group|
        string << "\n#### #{gender.to_s.humanize}\n"
        group.each do |status, taxa|
          string << "\n###### #{status.to_s.humanize}\n" <<
            taxa.map { |taxon| "%taxon#{taxon.id}"}.join(", ") << "\n"
        end
      end
      string
    end

    def not_matching_any_endings
      any_ending = endings.values.flatten.join("|")
      Genus.where("name_cache NOT REGEXP ?", "#{any_ending}$").order_by_name_cache
    end

    def formatted_not_matching_any_endings
      string = "\n### Not matching any ending\n"
      string << not_matching_any_endings.map do |taxon|
        "%taxon#{taxon.id}"
      end.join(", ")
    end

    def render
      markdown formatted_statistics <<
        formatted_matches <<
        formatted_not_matching_any_endings
    end

    private
      # "-lepis" was included twice, removed from the masculine list.
      # Removed overlapping endings: "-lasius" (masculine), "-um" (neuter).
      def endings
        { feminine: %w(idris myrma ponera pone formica myrmica gaster ella ia ula),
          masculine: %w(myrmex oides ius),
          neuter: %w(omma noma ium) }
      end

      def sort_results output
        output.each_value do |gender|
          gender.each_value do |by_status|
            by_status.sort_by! {|taxon| taxon.name_cache }
          end
        end
        output
      end
  end
end

__END__
description: Version 0.1 of this script. Read-only.
tags: [slow]
topic_areas: [catalog]
