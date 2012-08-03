# coding: UTF-8
require 'spec_helper'

describe Exporters::Antweb::Formatter do
  before do
    @formatter = Exporters::Antweb::Formatter
  end

  describe "it" do
    it "should" do
      @formatter.new(create_genus, nil).format
    end
  end
end
