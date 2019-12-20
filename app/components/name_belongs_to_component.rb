class NameBelongsToComponent < ActionView::Component::Base
  def initialize(name:)
    @name = name
  end

  private

    attr_reader :name
end
