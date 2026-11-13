# frozen_string_literal: true

# View component: a dropdown menu with a title (used in the page header and on record pages).
class DropdownComponent < ApplicationComponent
  def initialize title
    @title = title
    @dropdown_name = SecureRandom.uuid
  end

  private

    attr_reader :title, :dropdown_name
end
