require 'spec_helper'

describe Subtribe do
  let(:subtribe) { described_class.new }

  describe "#parent=" do
    specify do
      expect { subtribe.parent = nil }.to raise_error(NotImplementedError)
    end
  end

  describe "#update_parent" do
    specify do
      expect { subtribe.update_parent(nil) }.to raise_error("cannot update parent of subtribes")
    end
  end

  describe "#children" do
    specify do
      expect { subtribe.children }.to raise_error(NotImplementedError)
    end
  end
end
