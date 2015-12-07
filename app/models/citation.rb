# coding: UTF-8
class Citation < ActiveRecord::Base
  include UndoTracker

  #belongs_to :reference, -> { includes :author_names}   # has a reference_id
  belongs_to :reference   # has a reference_id

  validates :reference, presence: true
  has_paper_trail meta: { change_id: :get_current_change_id}
  attr_accessible :pages, :forms, :id, :reference_id, :reference, :notes_taxt

  include CleanNewlines
  before_save {|record| clean_newlines record, :notes_taxt}

  def authorship_string
    reference and "#{author_names_string}, #{reference.year}"
  end

  def authorship_html_string
    reference and reference.decorate.format_authorship_html
  end

  def author_last_names_string
    reference and "#{author_names_string}"
  end

  def year
    reference and reference.year.to_s
  end

  def author_names_string
    names = reference.author_names.map &:last_name
    case names.size
    when 0
      '[no authors]'
    when 1
      "#{names.first}"
    when 2
      "#{names.first} & #{names.second}"
    else
      string = names[0..-2].join ', '
      string << " & " << names[-1]
    end
  end

end