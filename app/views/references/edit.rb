class Views::References::Edit < Erector::Widgets::Page

  def head_content
    super
    javascript_include_tag 'ext/jquery-1.4.2.js'
    css '/stylesheets/application.css'
    jquery "$('input').first().focus()"
  end

  def page_title
    "ANTBIB"
  end

  def body_content
    div :id => 'container' do
      h3 'ANTBIB'
      hr

      super
      h2 "Edit Reference"

      form_for([:reference, @reference], :method => "put", :url => { :controller => "references", :action => "update" }) do |f|
        widget Views::References::Form, :f => f
        p do
          link_to 'Back', references_path
        end
      end
    end
  end
end
