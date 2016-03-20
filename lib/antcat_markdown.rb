# Probably GitHub markdown (?) with some custom tags.

class AntcatMarkdown < Redcarpet::Render::HTML

  def self.render text
    options = {
      hard_wrap: true,
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      autolink: true,
      superscript: true,
      disable_indented_code_blocks: true
    }

    renderer = AntcatMarkdown.new options
    markdown = Redcarpet::Markdown.new renderer, extensions

    markdown.render(text).html_safe
  end

  def preprocess full_document
    parsed = parse_taxon_ids full_document
    parsed = parse_reference_ids parsed
    parsed = parse_taxon_ids_list parsed
    parsed
  end

  private
    # matches: %429349
    # renders: link to the taxon (Formica)
    def parse_taxon_ids full_document
      full_document.gsub(/%t?(\d+)/) do
        try_linking_taxon_id $1
      end
    end

    # matches: %r130628
    # renders: referece as used in the catalog (Abdalla & Cruz-Landim, 2001)
    def parse_reference_ids full_document
      full_document.gsub(/%r(\d+)/) do
        if Reference.exists? $1
          reference = Reference.find($1)
          reference.decorate.to_link
        else
          $1
        end
      end
    end

    # matches: %tl[497190, 497191, 497192]
    # renders: links to the taxa, separated by comma
    def parse_taxon_ids_list full_document
      full_document.gsub(/%tl\[(.*?)\]/) do
        ids_string = $1
        ids = ids_string.gsub(" ", "").split(",")

        ids.map do |id|
          try_linking_taxon_id id
        end.join(", ")
      end
    end

    # internal only
    def try_linking_taxon_id string
      if Taxon.exists? string
        taxon = Taxon.find(string)
        taxon.decorate.link_to_taxon
      else
        string
      end
    end
end
