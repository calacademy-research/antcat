class SpeciesGroupName < Name
  include Formatters::ItalicsHelper

  before_validation :set_epithets

  def name_html
    italicize name
  end

  def epithet_html
    italicize epithet
  end

  def genus_epithet
    name_parts[0]
  end

  def species_epithet
    name_parts[1]
  end

  def dagger_html
    italicize super
  end

  private

    def set_epithets
      return unless name
      without_subgenus_name_part = name.gsub(/\(.*?\)/, '').squish
      self.epithets = if without_subgenus_name_part.split(' ').size > 2
                        name_parts[1..-1].join(' ')
                      end
    end

    def change name_string
      existing_names = Name.where.not(id: id).where(name: name_string)
      raise Taxon::TaxonExists if existing_names.any? { |name| !name.what_links_here.empty? }
      self.name = name_string
    end
end
