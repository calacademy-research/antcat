require 'curl'

class Scraper
  def get url
    Nokogiri::HTML(Curl::Easy.perform(url).body_str)
  end
end
