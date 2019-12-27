require 'rails_helper'

describe ReferenceSection do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :taxon }

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
