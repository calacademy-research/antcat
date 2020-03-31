# frozen_string_literal: true

require 'rails_helper'

describe ActivityTemplatePartial do
  context "without a `trackable_type`" do
    it "returns the template for the `action`" do
      expect(described_class[action: 'elevate_subspecies_to_species', trackable_type: nil]).
        to eq "activities/templates/actions/elevate_subspecies_to_species"
    end
  end

  context "with a `trackable_type`" do
    context "when there is a partial matching `trackable_type`" do
      it "returns the template for the `trackable_type`" do
        expect(described_class[action: nil, trackable_type: 'Journal']).
          to eq "activities/templates/journal"
      end
    end

    context "when there is no partial matching `trackable_type`" do
      it "returns the default template" do
        expect(described_class[action: nil, trackable_type: 'Pizza']).
          to eq "activities/templates/default"
      end
    end
  end
end
