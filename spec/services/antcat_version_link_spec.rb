# frozen_string_literal: true

require 'rails_helper'

describe AntCatVersionLink do
  describe "#call" do
    specify do
      expect(described_class.new.call).to include %(href="https://github.com/calacademy-research/antcat/commit/)
    end
  end
end
