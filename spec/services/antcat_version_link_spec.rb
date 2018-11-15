require 'spec_helper'

describe AntcatVersionLink do
  describe "#call" do
    specify do
      expect(described_class.new.call).to include %(href="https://github.com/calacademy/antcat/commit/)
    end
  end
end
