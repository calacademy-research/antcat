# frozen_string_literal: true

Capybara.add_selector(:testid) do
  css { |testid| "*[data-testid=#{testid}]" }
end
