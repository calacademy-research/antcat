# coding: UTF-8
require 'spec_helper'

describe ReferenceKey do

  before do
    @bolton = FactoryGirl.create :author_name, name: 'Bolton, B.'
    @fisher = FactoryGirl.create :author_name, name: 'Fisher, B.'
    @ward = FactoryGirl.create :author_name, name: 'Ward, P.S.'
  end

  it "should output a {ref xxx} for Taxt" do
    reference = FactoryGirl.create :article_reference, :author_names => [@bolton], citation_year: '1970a'
    ReferenceKey.new(reference).to_taxt.should == "{ref #{reference.id}}"
  end

  describe "Representing as a string" do
    it "should be blank if a new record" do
      BookReference.new.key.to_s.should == ''
    end
    it "Citation year with extra" do
      reference = FactoryGirl.create :article_reference, :author_names => [@bolton], citation_year: '1970a ("1971")'
      reference.key.to_s.should == 'Bolton, 1970a'
    end
    it "No authors" do
      reference = FactoryGirl.create :article_reference, :author_names => [], citation_year: '1970a'
      reference.key.to_s.should == '[no authors], 1970a'
    end
    it "One author" do
      reference = FactoryGirl.create :article_reference, :author_names => [@bolton], citation_year: '1970a'
      reference.key.to_s.should == 'Bolton, 1970a'
    end
    it "Two authors" do
      reference = FactoryGirl.create :article_reference, :author_names => [@bolton, @fisher], citation_year: '1970a'
      reference.key.to_s.should == 'Bolton & Fisher, 1970a'
    end
    it "Three authors" do
      reference = FactoryGirl.create :article_reference, :author_names => [@bolton, @fisher, @ward], citation_year: '1970a'
      reference.key.to_s.should == 'Bolton, Fisher & Ward, 1970a'
    end
  end

  describe "Link" do
    before do
      latreille = FactoryGirl.create :author_name, name: 'Latreille, P. A.'
      science = FactoryGirl.create :journal, name: 'Science'
      @reference = FactoryGirl.create :article_reference, author_names: [latreille], citation_year: '1809', title: "*Atta*", journal: science, series_volume_issue: '(1)', pagination: '3'
      @reference.stub(:url).and_return 'example.com'
    end
    it "should create a link to the reference" do
      @reference.stub(:downloadable_by?).and_return true
      @reference.key.to_link(nil).should ==
        %{<span class="reference_key_and_expansion">} +
          %{<a class="reference_key" href="#" title="Latreille, P. A. 1809. Atta. Science (1):3.">Latreille, 1809</a>} +
          %{<span class="reference_key_expansion">} +
            %{<span class="reference_key_expansion_text" title="Latreille, 1809">Latreille, P. A. 1809. <i>Atta</i>. Science (1):3.</span>} +
            %{ } +
            %{<a class="document_link" href="example.com" target="_blank">PDF</a>} +
            %{<a class="goto_reference_link" href="/references?q=#{@reference.id}" target="_blank"><img alt="External_link" src="/assets/external_link.png" /></a>} +
          %{</span>} +
        %{</span>}
    end
    it "should create a link to the reference without the PDF link if the user isn't logged in" do
      @reference.stub(:downloadable_by?).and_return false
      @reference.key.to_link(nil).should ==
        %{<span class="reference_key_and_expansion">} +
          %{<a class="reference_key" href="#" title="Latreille, P. A. 1809. Atta. Science (1):3.">Latreille, 1809</a>} +
          %{<span class="reference_key_expansion">} +
            %{<span class="reference_key_expansion_text" title="Latreille, 1809">Latreille, P. A. 1809. <i>Atta</i>. Science (1):3.</span>} +
            %{<a class="goto_reference_link" href="/references?q=#{@reference.id}" target="_blank"><img alt="External_link" src="/assets/external_link.png" /></a>} +
          %{</span>} +
        %{</span>}
    end
    describe "When expansion is not desired" do
      it "should not include the PDF link, if not available to the user" do
        @reference.stub(:downloadable_by?).and_return false
        @reference.key.to_link(nil, expansion: false).should ==
          %{<a href="http://antcat.org/references?q=#{@reference.id}" target="_blank" title="Latreille, P. A. 1809. Atta. Science (1):3.">Latreille, 1809</a>}
      end
      it "should include the PDF link, if available to the user" do
        @reference.stub(:downloadable_by?).and_return true
        @reference.key.to_link(nil, expansion: false).should ==
          %{<a href="http://antcat.org/references?q=#{@reference.id}" target="_blank" title="Latreille, P. A. 1809. Atta. Science (1):3.">Latreille, 1809</a>} +
          %{ } +
          %{<a class="document_link" href="example.com" target="_blank">PDF</a>}
      end
    end
    describe "Handling quotes in the title" do
      it "should escape them, but just once" do
        latreille = FactoryGirl.create :author_name, name: 'Latreille, P. A.'
        @reference = FactoryGirl.create :unknown_reference, author_names: [latreille], citation_year: '1809', title: '"Atta"'
        @reference.key.to_link(nil, expansion: false).should ==
          %{<a href="http://antcat.org/references?q=#{@reference.id}" target="_blank" title="Latreille, P. A. 1809. &quot;Atta&quot;. New York.">Latreille, 1809</a>}
      end
    end
  end

end
