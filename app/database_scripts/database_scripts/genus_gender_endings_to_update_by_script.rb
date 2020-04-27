# frozen_string_literal: true

module DatabaseScripts
  class GenusGenderEndingsToUpdateByScript < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

    def blank_to_feminine
      endings_regex = endings[:feminine].join('|')
      Genus.joins(:name).
        where("names.gender IS NULL").where("name_cache REGEXP ?", "(#{endings_regex})$").
        order_by_name
    end

    def blank_to_masculine
      endings_regex = endings[:masculine].join('|')
      Genus.joins(:name).
        where("names.gender IS NULL").where("name_cache REGEXP ?", "(#{endings_regex})$").
        order_by_name
    end

    def blank_to_neuter
      endings_regex = endings[:neuter].join('|')
      Genus.joins(:name).
        where("names.gender IS NULL").where("name_cache REGEXP ?", "(#{endings_regex})$").
        order_by_name
    end

    def unaccounted_blanks
      accounted_for_ids =
        blank_to_feminine.pluck(:id) +
        blank_to_masculine.pluck(:id) +
        blank_to_neuter.pluck(:id)

      Genus.joins(:name).where("names.gender IS NULL").where.not(id: accounted_for_ids)
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
        end <<
        as_table do |t|
          taxa = unaccounted_blanks

          t.header 'Genus', 'Current gender', 'Set to gender'
          t.caption "Total: #{taxa.count}. Genera with blank gender, excluding records in the above tables."
          t.rows(taxa) do |taxon|
            [
              taxon_link(taxon),
              taxon.name.gender || '[blank]',
              '[will not be changed]'
            ]
          end
        end
    end

    private

      def endings
        {
          feminine: %w[a e opsis lepis],
          masculine: %w[er es ops os us],
          neuter: %w[on um]
        }
      end
  end
end

__END__

section: pa-no-action-required
category: Catalog
tags: [updated!]

issue_description:

description: >
  * Done: *Batch 1) genera with a blank gender* - %github997


  * Done: *Batch 2) more genera with blank gender* - %github997

related_scripts:
  - GenusGenderEndings
  - GenusGenderEndingsToUpdateByScript
