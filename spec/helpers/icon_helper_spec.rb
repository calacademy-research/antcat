# frozen_string_literal: true

require 'rails_helper'

describe IconHelper do
  describe "#antcat_icon" do
    context "when input is a string" do
      specify { expect(helper.antcat_icon("issue")).to include 'class="antcat_icon issue"' }
    end

    context "when input in a multi-word string" do
      specify { expect(helper.antcat_icon("issue open")).to include 'class="antcat_icon issue open"' }
    end

    context "when input is an array" do
      specify { expect(helper.antcat_icon(["issue open"])).to include 'class="antcat_icon issue open"' }
      specify { expect(helper.antcat_icon(["issue", "open"])).to include 'class="antcat_icon issue open"' }
    end
  end
end
