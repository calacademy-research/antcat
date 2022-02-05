# frozen_string_literal: true

Given("there is a subfamily {string}") do |name|
  create :subfamily, name_string: name
end

Given("there is an invalid subfamily Invalidinae") do
  create :subfamily, :unidentifiable, name_string: "Invalidinae"
end
