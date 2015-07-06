# coding: UTF-8
class GenusName < GenusGroupName
  extend Formatters::Formatter
  has_paper_trail meta: {change_id: :get_current_change_id}
  include UndoTracker

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
