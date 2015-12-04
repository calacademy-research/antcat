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
end