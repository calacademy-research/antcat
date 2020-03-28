# frozen_string_literal: true

require 'rails_helper'

describe Subgenus do
  describe 'relations' do
    it { is_expected.to have_many(:species).dependent(:restrict_with_error) }
    it { is_expected.to belong_to(:genus).required }
  end

  describe "#update_parent" do
    specify do
      expect { described_class.new.update_parent(nil) }.to raise_error("cannot update parent of subgenera")
    end
  end
end
