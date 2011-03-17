require 'spec_helper'

describe Antweb::Diff do
  before do
    @diff = Antweb::Diff.new
  end

  it "should report no matches when there are none" do
    antcat = ["A\t\t\t\t1"]
    antweb = ["B\t\t\t\t1"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 0
    @diff.difference_count.should == 0
    @diff.antcat_unmatched_count.should == 1
    @diff.antweb_unmatched_count.should == 1
    @diff.differences.should == []
  end

  it "should report one match when there is one match" do
    antcat = ["A\t\t\t\t1"]
    antweb = ["A\t\t\t\t1"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 1
    @diff.difference_count.should == 0
    @diff.antcat_unmatched_count.should == 0
    @diff.antweb_unmatched_count.should == 0
    @diff.differences.should == []
  end

  it "should report one difference when there is one difference" do
    antcat = ["A\t\t\t\t1"]
    antweb = ["A\t\t\t\t2"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 0
    @diff.difference_count.should == 1
    @diff.antcat_unmatched_count.should == 0
    @diff.antweb_unmatched_count.should == 0
    @diff.differences.should == [["A\t\t\t\t1", "A\t\t\t\t2"]]
  end

  it "should handle a mix" do
    antcat = ["A\t\t\t\t1", "A\t\t\t\t2","C\t\t\t\t1"]
    antweb = ["A\t\t\t\t2", "C\t\t\t\t3","D\t\t\t\t1"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 1
    @diff.difference_count.should == 1
    @diff.antcat_unmatched_count.should == 1
    @diff.antweb_unmatched_count.should == 1
    @diff.differences.should == [["C\t\t\t\t1", "C\t\t\t\t3"]]
  end

  it "should ignore the validity and availability of Pseudoatta, since Bolton had a typo which I corrected" do
    antcat = ["Myrmicinae\tAttini\tPseudoatta\t\t\t\tTRUE\tTRUE\tPseudoatta\t"]
    antweb = ["Myrmicinae\tAttini\tPseudoatta\t\t\t\tfalse\tfalse\t\t"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 1
  end

  it "should ignore the validity and availability of Paraprionopelta, since Bolton had a typo which I corrected, and also shouldn't care if it doesn't have a tribe" do
    Factory :genus, :name => 'Paraprionopelta', :tribe => Factory(:tribe, :name => 'Amblyoponini')
    antcat = ["Amblyoponinae\tAmblyoponini\tParaprionopelta\t\t\t\tTRUE\tTRUE\tParaprionopelta\t"]
    antweb = ["Amblyoponinae\t\tParaprionopelta\t\t\t\tfalse\tfalse\t\t"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 1
  end

  it "should ignore the validity and availability of Asphinctanilloides, since Bolton had a typo which I corrected" do
    Factory :genus, :name => 'Asphinctanilloides', :tribe => Factory(:tribe, :name => 'Leptanilloidini')
    antcat = ["Leptanilloidinae\tLeptanilloidini\tAsphinctanilloides\t\t\t\tTRUE\tTRUE\tAsphinctanilloides\t"]
    antweb = ["Leptanilloidinae\t\tAsphinctanilloides\t\t\t\tfalse\tfalse\t\t"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 1
  end

  it "should ignore the difference if it's just that AntCat has a genus's tribe but AntWeb doesn't" do
    Factory :genus, :name => 'Adetomyrma', :tribe => Factory(:tribe, :name => 'Aenictini')
    antcat = ["Amblyoponinae\t" + "Aenictini\t" + "Adetomyrma\t\t\t\tTRUE\tTRUE\tPseudoatta\t"]
    antweb = ["Amblyoponinae\t" + "\t"          + "Adetomyrma\t\t\t\tTRUE\tTRUE\tPseudoatta\t"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 1
  end

  it "should ignore the difference if it's just that AntWeb didn't pick up the tribe properly" do
    antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\tPropodilobus\t"]
    antweb = ["Myrmicinae\tincertae sedis in Stenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\tPropodilobus\t"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 1
  end

  describe "judging the similarity of taxonomic histories" do

    it "should not ignore the difference if the first words aren't the same" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\tPropodilobus\t\tFoo"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\tPropodilobus\t\tBar"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 0
    end

    it "should ignore the difference if the first words are the same except for case" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\tPropodilobus\t\tPropodilobus"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\tPropodilobus\t\tPROPODILOBUS"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 1
    end

    it "should not ignore the difference if the first words are the same except for case but the rest isn't a match" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tPropodilobus Much longer taxonomic history"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tPROPODILOBUS Different taxonomic history"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 0
    end

    it "should ignore the difference if AntCat is just the name + [junior synonym of]" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\tPropodilobus\t\tPropodilobus Much longer taxonomic history"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\tPropodilobus\t\tPROPODILOBUS [junior synonym of Athropus ]"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 1
    end

  end

  describe "showing where two strings differ" do

    it "should return nil if they're equal" do
      Antweb::Diff.new.match_fails_at('abc', 'abc').should == nil
    end

    it "should return 0 if they differ at the first character" do
      Antweb::Diff.new.match_fails_at('a', 'b').should == 0
    end

    it "should return the size of the shorter string if it's a substring of the other" do
      Antweb::Diff.new.match_fails_at('ab', 'a').should == 1
    end
  
  end

end
