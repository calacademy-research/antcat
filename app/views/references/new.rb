class Views::References::New < Erector::Widgets::Page

  def head_content
    super
    javascript_include_tag 'ext/jquery-1.4.2.js'
    css '/stylesheets/application.css'
    jquery "$('#author').focus()"
  end

  def page_title
    "ANTBIB"
  end


  def body_content
    div :id => 'container' do
      h3 'ANTBIB'
      hr

      super
      h2 "Add Reference"

      form_for([:reference, @reference], :url => references_path) do |f|
        widget Views::References::Form, :f => f, :submit_text => "Add"
        p do
          link_to 'Back', references_path
        end
      end
    end
  end
end
