# frozen_string_literal: true

require 'rails_helper'

describe Subtribe do
  describe 'relations' do
    it { is_expected.to belong_to(:subfamily).required }
    it { is_expected.to belong_to(:tribe).required }
  end

  describe "#parent" do
    let(:subtribe) { build_stubbed :subtribe }

    specify { expect(subtribe.parent).to eq subtribe.tribe }
  end

  describe "#parent=" do
    let(:subtribe) { described_class.new }

    specify { expect { subtribe.parent = nil }.to raise_error("cannot update parent of subtribes") }
  end

  describe "#update_parent" do
    let(:subtribe) { described_class.new }

    specify do
      expect { subtribe.update_parent(nil) }.to raise_error("cannot update parent of subtribes")
    end
  end
end