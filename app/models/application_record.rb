# Currently only subclassed by a couple of models.

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # TODO find out if it's possible to add scopes here. Candidates:
  # order_by_date, most_recent

  # TODO make more use of this.
  def make_not_auto_generated!
    return unless auto_generated?
    self.auto_generated = false
    save
  end
end
