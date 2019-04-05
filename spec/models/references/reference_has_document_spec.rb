require 'spec_helper'

describe Reference do
  it { is_expected.to have_one :document }

  it { is_expected.to delegate_method(:url).to(:document).allow_nil }
  it { is_expected.to delegate_method(:downloadable?).to(:document).allow_nil }
end
