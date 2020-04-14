# frozen_string_literal: true

require 'rails_helper'

describe ReferenceSection do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to belong_to(:taxon).required }
  end

  describe 'callbacks' do
    it_behaves_like "a taxt column with cleanup", :references_taxt do
      subject { build :reference_section }
    end

    it_behaves_like "a taxt column with cleanup", :subtitle_taxt do
      subject { build :reference_section }
    end

    it_behaves_like "a taxt column with cleanup", :title_taxt do
      subject { build :reference_section }
    end
  end
end
