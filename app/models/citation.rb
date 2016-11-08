# TODO. All method in this class: DRY and w.r.t. `ReferenceDecorator`.

class Citation < ActiveRecord::Base
  include UndoTracker

  attr_accessible :pages, :forms, :id, :reference_id, :reference, :notes_taxt

  belongs_to :reference

  validates :reference, presence: true

  before_save { CleanNewlines.clean_newlines self, :notes_taxt }

  has_paper_trail meta: { change_id: :get_current_change_id }

  # TODO same as "keey" but without letters in the year.
  def authorship_string
    reference.decorate.keey_without_letters_in_year
  end

  # TODO only caller of `ReferenceDecorator#format_authorship_html`.
  # TODO HTML probably do not belong here.
  def authorship_html_string
    reference.decorate.format_authorship_html
  end

  # TODO rename / remove.
  def author_last_names_string
    reference.decorate.authors_for_keey
  end

  # TODO something.
  def year
    $stdout.puts "someone called Citation#year".blue
    reference.decorate.year_or_no_year
  end
end
