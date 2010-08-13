class Views::References::Reference < Erector::Widget
  needs :reference => nil, :class => 'reference'

  def content
    @reference ||= Reference.new
    div :id => "reference_#{@reference.id}", :class => @class do
      widget Views::References::Display.new :reference => @reference
      widget Views::References::Form.new :reference => @reference
      widget Views::Coins.new :reference => @reference
    end
  end
end
