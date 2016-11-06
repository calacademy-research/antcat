# Currently only subclassed by a couple of models.

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # TODO make more use of this.
  def make_not_auto_generated!
    return unless auto_generated?
    self.auto_generated = false
    save
  end
end
