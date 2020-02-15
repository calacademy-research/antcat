require 'rails_helper'

describe Subgenus do
  it { is_expected.to validate_presence_of :genus }

  describe 'relations' do
    it { is_expected.to have_many(:species).dependent(:restrict_with_error) }
  end

  describe "#update_parent" do
    specify do
      expect { described_class.new.update_parent(nil) }.to raise_error("cannot update parent of subgenera")
    end
  end
end
