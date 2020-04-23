# frozen_string_literal: true

module DatabaseScripts
  class GenusGenderEndingsToUpdateByScript < DatabaseScript
    def blank_to_feminine
      endings_regex = endings[:feminine].join('|')
      Genus.joins(:name).
        where("names.gender IS NULL").where("name_cache REGEXP ?", "#{endings_regex}$").
        order_by_name
    end

    def blank_to_masculine
      endings_regex = endings[:masculine].join('|')
      Genus.joins(:name).
        where("names.gender IS NULL").where("name_cache REGEXP ?", "#{endings_regex}$").
        order_by_name
    end

    def blank_to_neuter
      endings_regex = endings[:neuter].join('|')
      Genus.joins(:name).
        where("names.gender IS NULL").where("name_cache REGEXP ?", "#{endings_regex}$").
        order_by_name
    end

    def render
      as_table do |t|
        taxa = blank_to_feminine
        gender = :feminine

        t.header 'Genus', 'Current gender', 'Set to gender'
        t.caption "Total: #{taxa.count}. Feminine endings: #{endings[gender].join(', ')}."
        t.rows(taxa) do |taxon|
          [
            taxon_link(taxon),
            taxon.name.gender || '[blank]',
            gender
          ]
        end
      end <<
        as_table do |t|
          taxa = blank_to_masculine
          gender = :masculine

          t.header 'Genus', 'Current gender', 'Set to gender'
          t.caption "Total: #{taxa.count}. Masculine endings: #{endings[gender].join(', ')}."
          t.rows(taxa) do |taxon|
            [
              taxon_link(taxon),
              taxon.name.gender || '[blank]',
              gender
            ]
          end
        end <<
        as_table do |t|
          taxa = blank_to_neuter
          gender = :neuter

          t.header 'Genus', 'Current gender', 'Set to gender'
          t.caption "Total: #{taxa.count}. Neuter endings: #{endings[gender].join(', ')}."
          t.rows(taxa) do |taxon|
            [
              taxon_link(taxon),
              taxon.name.gender || '[blank]',
              gender
            ]
          end
        end
    end

    private

      # "-lepis" was included twice, removed from the masculine list.
      # Removed overlapping endings: "-lasius" (masculine), "-um" (neuter).
      def endings
        {
          feminine: %w[idris myrma ponera pone formica myrmica gaster ella ia ula],
          masculine: %w[myrmex oides ius],
          neuter: %w[omma noma ium]
        }
      end
  end
end

__END__

section: pa-no-action-required
category: Catalog
tags: [new!]

issue_description:

description: >
  Batch 1) genera with a blank gender

related_scripts:
  - GenusGenderEndings
  - GenusGenderEndingsToUpdateByScript
