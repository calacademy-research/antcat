require 'test_helper'

class ReferenceTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Reference.new.valid?
  end
end
