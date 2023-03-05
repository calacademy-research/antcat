# frozen_string_literal: true

class DropdownComponent < ApplicationComponent
  def initialize title
    @title = title
    @dropdown_name = SecureRandom.uuid
  end

  private

    attr_reader :title, :dropdown_name
end
