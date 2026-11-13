# frozen_string_literal: true

# The base of the app's database models.
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
