# -*- encoding: UTF-8 -*-
require 'active_record'
require 'yaml'
require 'json'
require 'logger'
require './models/user'
require './models/settings/service'

class FeedCollector

  def initialize(env = 'development')
    @logger = Logger.new STDOUT
    @crawlers = find_crawlers
    config = YAML.load_file './config/database.yml'
    ActiveRecord::Base.establish_connection config[env]
  end

  def start
    @crawlers.each do |c|
      Settings::Service.find_each(:conditions => { :name => c.class.name.sub(/Crawler/, '').downcase }) do |service|
        c.account = JSON.parse service.authorization
        c.user = service.user
        c.run
      end
    end
  end

  private 
  #
  # crawler を探す
  #
  def find_crawlers
    # TODO: 自動で crawler を探すようにする
    require './crawlers/twitter_crawler'
    [TwitterCrawler.new()]
  end
end

FeedCollector.new.start
