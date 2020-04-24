# frozen_string_literal: true

module DatabaseScripts
  class GenusGenderEndings < DatabaseScript # rubocop:disable Metrics/ClassLength
    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

    def statistics
      first_pass_feminine_count = first_pass_feminine.count
      first_pass_masculine_count = first_pass_masculine.count
      first_pass_neuter_count = first_pass_neuter.count
      second_pass_feminine_count = second_pass_feminine.count
      second_pass_masculine_count = second_pass_masculine.count
      second_pass_neuter_count = second_pass_neuter.count
      unaccounted_for_genera_count = unaccounted_for_genera.count

      all_above_count =
        first_pass_feminine_count +
        first_pass_masculine_count +
        first_pass_neuter_count +
        second_pass_feminine_count +
        second_pass_masculine_count +
        second_pass_neuter_count +
        unaccounted_for_genera_count

      <<~RESULTS.html_safe
        First-pass feminine: #{first_pass_feminine_count}<br>
        First-pass masculine: #{first_pass_masculine_count}<br>
        First-pass neuter: #{first_pass_neuter_count}<br>
        <br>
        Second-pass feminine: #{second_pass_feminine_count}<br>
        Second-pass masculine: #{second_pass_masculine_count}<br>
        Second-pass neuter: #{second_pass_neuter_count}<br>
        <br>
        Unaccounted for genera: #{unaccounted_for_genera_count}<br>
        All above: #{all_above_count}<br>
        Genus count (total): #{Genus.count}
      RESULTS
    end

    def first_pass_feminine
      endings_regex = first_pass_endings[:feminine].join('|')
      Genus.joins(:name).where("name_cache REGEXP ?", "(#{endings_regex})$")
    end

    def first_pass_masculine
      endings_regex = first_pass_endings[:masculine].join('|')
      Genus.joins(:name).where("name_cache REGEXP ?", "(#{endings_regex})$")
    end

    def first_pass_neuter
      endings_regex = first_pass_endings[:neuter].join('|')
      Genus.joins(:name).where("name_cache REGEXP ?", "(#{endings_regex})$")
    end

    def genera_for_second_pass
      first_pass_ids =
        first_pass_feminine.pluck(:id) +
        first_pass_masculine.pluck(:id) +
        first_pass_neuter.pluck(:id)

      Genus.where.not(id: first_pass_ids)
    end

    def second_pass_feminine
      endings_regex = second_pass_endings[:feminine].join('|')
      genera_for_second_pass.joins(:name).where("name_cache REGEXP ?", "(#{endings_regex})$")
    end

    def second_pass_masculine
      endings_regex = second_pass_endings[:masculine].join('|')
      genera_for_second_pass.joins(:name).where("name_cache REGEXP ?", "(#{endings_regex})$")
    end

    def second_pass_neuter
      endings_regex = second_pass_endings[:neuter].join('|')
      genera_for_second_pass.joins(:name).where("name_cache REGEXP ?", "(#{endings_regex})$")
    end

    def unaccounted_for_genera
      second_pass_ids =
        second_pass_feminine.pluck(:id) +
        second_pass_masculine.pluck(:id) +
        second_pass_neuter.pluck(:id)

      genera_for_second_pass.where.not(id: second_pass_ids)
    end

    def render
      section_table(first_pass_feminine, :feminine, first_pass_endings[:feminine], "Feminine endings (first pass)") <<
        section_table(first_pass_masculine, :masculine, first_pass_endings[:masculine], "Masculine endings (first pass)") <<
        section_table(first_pass_neuter, :neuter, second_pass_endings[:neuter], "Neuter endings (first pass)") <<
        section_table(second_pass_feminine, :feminine, second_pass_endings[:feminine], "Feminine endings (second pass)") <<
        section_table(second_pass_masculine, :masculine, second_pass_endings[:masculine], "Masculine endings (second pass)") <<
        section_table(second_pass_neuter, :neuter, second_pass_endings[:neuter], "Neuter endings (second pass)") <<
        as_table do |t|
          taxa = unaccounted_for_genera.order_by_name

          t.header 'Genus', 'Gender'
          t.caption "Total: #{taxa.count}. Unaccounted for genera."
          t.rows(taxa) do |taxon|
            current_gender = taxon.name.gender || '[blank]'

            [
              taxon_link(taxon),
              current_gender
            ]
          end
        end
    end

    private

      attr_accessor :listed_ids

      # "-lepis" was included twice, removed from the masculine list.
      # Removed overlapping endings: "-lasius" (masculine), "-um" (neuter).
      def first_pass_endings
        {
          feminine: %w[idris myrma ponera pone formica myrmica gaster ella ia ula],
          masculine: %w[myrmex oides ius],
          neuter: %w[omma noma ium]
        }
      end

      # These can only be applied once the above endings have been assigned.
      def second_pass_endings
        {
          feminine: %w[a e opsis],
          masculine: %w[er es ops os us],
          neuter: %w[on um]
        }
      end

      def section_table taxa, section_gender, endings, caption
        as_table do |t|
          t.header 'Genus', 'Gender'
          t.caption "Total: #{taxa.count}. #{caption}: #{endings.join(', ')}."
          t.rows(taxa.order_by_name) do |taxon|
            current_gender = taxon.name.gender || '[blank]'
            correctly_gendered = current_gender == section_gender.to_s

            [
              taxon_link(taxon),
              (correctly_gendered ? current_gender : bold_warning(current_gender))
            ]
          end
        end
      end
  end
end

__END__

section: list
category: Names
tags: [updated!, slow]

related_scripts:
  - GenusGenderEndings
  - GenusGenderEndingsToUpdateByScript
