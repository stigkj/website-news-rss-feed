require 'sinatra'
require 'rack/cache'

require 'nokogiri'
require 'open-uri'
require 'rss'

use Rack::Cache do
  set :metastore, 'heap:/'
  set :entitystore, 'heap:/'
end

get '/' do
  cache_control :public, :must_revalidate, :max_age => 60

  rss = RSS::Maker.make('atom') do |maker|
    maker.channel.author = 'NOS Clearing ASA'
    maker.channel.updated = Time.now.to_s
    maker.channel.about = 'http://www.nosclearing.com'
    maker.channel.title = 'NOS Clearing News'

    doc = Nokogiri::HTML(open('http://www.nosclearing.com/news/category202.html'))

    doc.xpath('//tr/td[@class="loc-and-date"]/..').each do |tr|
      maker.items.new_item do |item|
        item.link = tr.at_xpath('.//a/@href').content
        item.title = tr.at_xpath('.//a').content
        item.updated = tr.at_xpath('.//span').content
      end
    end
  end

  rss.to_s
end