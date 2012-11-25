# -*- encoding: UTF-8 -*-
require 'net/http'
require 'json'
require 'base64'
require 'date'
require 'digest/hmac'
require 'yaml'
require 'logger'
require './crawlers/morphological_analysis'
require './crawlers/wikipedia_client'
require './crawlers/twitter_client'
require './models/page'

class TwitterCrawler

    attr_accessor :user

    def initialize
        @logger = Logger.new(STDOUT)
        @parser = MorphologicalAnalysis.new
        @category_parser = WikipediaClient.new('ja')
        twitter_config = YAML.load_file './config/twitter.yml'
        @twitter = TwitterClient.new twitter_config['oauth_consumer_key'], twitter_config['oauth_consumer_secret']
    end

    def run
        last_page = user.pages.order('url DESC').first
        request_params = { :trim_user => true }
        unless last_page.nil?
            request_params[:since_id] = last_page.url.split('/')[-1]
        end
        analyze_posts 'statuses/user_timeline', request_params 
    end

    def account=(account)
        @twitter.account = account;
    end

    private
    #
    # 投稿を取得し分析する
    #
    def analyze_posts(resource, request_params = {}) 
        home_timeline = @twitter.get_resource resource, request_params
        feeds = []
        home_timeline.each do |post|
            words = @parser.parse_to_node(post['text'].gsub(/http(s)?:\/\/[a-zA-Z0-9\/%#?=\.]*/, ''))
            categories = @category_parser.parse_to_categories(words)
            feed = self.user.pages.create(
                :url => "https://twitter.com/#{post['user']['screen_name']}/status/#{post['id_str']}",
                :tag0 => categories[0],
                :tag1 => categories[1],
                :tag2 => categories[2],
                :tag3 => categories[3],
                :tag4 => categories[4],
            )
            feeds.push(feed)
        end
        feeds
    end

end
