# coding: UTF-8
require 'spec_helper'

describe Parsers::PaginationGrammar do
  ['1 p., 5 maps',
    '12 + 532 pp.',
    '24 pp. 24 pls.',
    '247 pp. + 14 pl. + 4 pp. (index)',
    '312 + (posthumous section) 95 pp.',
    '5-187 + i-viii pp.',
    '5 maps',
    '8 pls., 84 pp.',
    'i-ii, 279-655',
    'xi',
    '93-114, 121',
    'P. 1',
    '33pp.',
    '33 pp.',
    'Pp. 63-396 (part)',
  ].each do |pagination|
    it "should handle '#{pagination}'" do
      Parsers::PaginationGrammar.parse(pagination).should == pagination
    end
  end

  it "shouldn't consider '4th' a pagination" do 
    Parsers::PaginationGrammar.parse('4th', :consume => false).should == '4'
  end

  it 'should handle a space after a hyphen' do
    Parsers::PaginationGrammar.parse('123- 4').should == '123- 4'
  end

  it 'should handle spaces around the hyphen' do
    Parsers::PaginationGrammar.parse('123 - 4').should == '123 - 4'
  end

  it 'should handle an ampersand between clauses' do
    Parsers::PaginationGrammar.parse('131-132 & 143-145').should == '131-132 & 143-145'
  end

end
