# TODO. All method in this class: DRY and w.r.t. `ReferenceDecorator`.

class Citation < ActiveRecord::Base
  include UndoTracker

  attr_accessible :pages, :forms, :id, :reference_id, :reference, :notes_taxt

  belongs_to :reference

  validates :reference, presence: true
  # FIX? the reference nil check is probably not needed outside of tests,
  # per `validates :reference, presence: true`.
  # TODO delegate in a smarter way to avoid duplicating Reference.

  before_save { CleanNewlines.clean_newlines self, :notes_taxt }

  has_paper_trail meta: { change_id: :get_current_change_id }

  # TODO Ruby's `and` keyword is evil.
  # TODO probably same as #keey.
  def authorship_string
    reference and "#{author_names_string}, #{year}"
  end

  # TODO only caller of `ReferenceDecorator#format_authorship_html`.
  # TODO HTML probably do not belong here.
  def authorship_html_string
    reference and reference.decorate.format_authorship_html
  end

  # TODO rename / remove.
  def author_last_names_string
    reference and "#{author_names_string}"
  end

  def year
    return "[no year]" unless reference && reference.year
    reference.year.to_s
  end

  private
    # TODO identical to the first part of #keey
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
