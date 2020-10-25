# frozen_string_literal: true

Given("there is an open feedback item") do
  create :feedback, user: nil
end

Given("there is a closed feedback item") do
  create :feedback, :closed
end
