# coding: UTF-8
class GenusName < GenusGroupName
  include Formatters::Formatter

  def genus_name
    words[0]
  end

  def genus_epithet
    genus_name
  end

  def self.parse_words words
    return unless words.size == 1
    create! make_import_attributes words[0]
  end

  def self.get_name data
    data[:genus_name]
  end

  def self.make_import_attributes name, _ = nil
    name_html = italicize name
    {
      name:         name,
      name_html:    name_html,
      epithet:      name,
      epithet_html: name_html,
      protonym_html:name_html,
    }
  end

end
