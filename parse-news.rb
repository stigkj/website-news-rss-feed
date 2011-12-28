#!/Users/gits/.rvm/rubies/ruby-1.9.2-p180/bin/ruby

require 'sinatra'
require 'rack/cache'
require 'haml'

require 'nokogiri'
require 'open-uri'
require 'rss'

=begin
use Rack::Cache
  :metastore => 'heap:/',
  :entitystore => 'heap:/'
=end

get '/' do
  cache_control :public, :must_revalidate, :max_age => 60

  rss = RSS::Maker.make('atom') do |maker|
    maker.channel.author = 'matz'
    maker.channel.updated = Time.now.to_s
    maker.channel.about = 'http://www.ruby-lang.org/en/feeds/news.rss'
    maker.channel.title = 'Example Feed'

    doc = Nokogiri::HTML(open('http://www.nosclearing.com/news/category202.html'))

    doc.xpath('//tr/td[@class="loc-and-date"]/..').each do |tr|
      loc_and_date = tr.at_xpath('.//span').content
      link2 = tr.at_xpath('.//a/@href').content
      title2 = tr.at_xpath('.//a').content

      maker.items.new_item do |item|
        item.link = link2
        item.title = title2
        item.updated = loc_and_date
      end
    end
  end

  rss.to_s
  #haml(:rss, :format => :xhtml, :escape_html => true, :layout => false)
end