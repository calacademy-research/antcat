# coding: UTF-8
require 'spec_helper'

describe Formatters::LinkFormatter do
  before do
    @formatter = Formatters::LinkFormatter
  end

  describe "Link creation" do
    describe "link" do
      it "should make a link to a new tab" do
        @formatter.link('Atta', 'www.antcat.org/1', title: '1').should ==
          %{<a href="www.antcat.org/1" target="_blank" title="1">Atta</a>}
      end
      it "should escape the name" do
        @formatter.link('<script>', 'www.antcat.org/1', title: '1').should ==
          %{<a href="www.antcat.org/1" target="_blank" title="1">&lt;script&gt;</a>}
      end
    end
    describe "link_to_external_site" do
      it "should make a link with the right class" do
        @formatter.link_to_external_site('Atta', 'www.antcat.org/1').should ==
          %{<a class="link_to_external_site" href="www.antcat.org/1" target="_blank">Atta</a>}
      end
    end
  end

end
