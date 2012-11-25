# -*- encoding: UTF-8 -*-
require 'net/http'
require 'logger'
require 'json'
require 'set'
require 'yaml'

class WikipediaClient 

    CONFIG = YAML.load_file './config/wikipedia.yml'

    attr_accessor :language

    def initialize(lang) 
        self.lang = lang
        @logger = Logger.new(STDOUT)
    end

    #
    # カテゴリーを解析する
    #
    def parse_to_categories(words) 
        categories = []
        categories += look_up_categories(words)
        return categories if categories.empty?
        @logger.debug categories
        # wikipedia から取得したカテゴリーはソートされているのでわざとシャッフルしている
        categories.shuffle.reduce(Hash.new(0)) { |result, category|
            result[category] += 1
            result
        }.sort { |a,b| b[1] <=> a[1] }.slice(0, 5).map{|a|a[0]}
    end

    private
    #
    # カテゴリーを取得する
    #
    def look_up_categories(words)
        words = words.join '|' if words.instance_of? Array
        return [] if words.empty?

        req_params = {'action' => 'query', 'prop' => 'categories|links', 'format' => 'json', 'titles' => URI::encode(words)}
        res = Net::HTTP.start(@uri.host, @uri.port, :use_ssl => @uri.port == 443) do |http|
            get = Net::HTTP::Get.new @uri.request_uri + '?' + req_params.map { |key, val| "#{key.to_s}=#{val.to_s}"}.join('&')
            http.request get
        end

        categories = []
        case res
        when Net::HTTPSuccess
            result = JSON.parse res.body
            result['query']['pages'].each do |pageid, page|
                page['categories'].to_a.each do |category|
                    c = category['title'].sub(@category_pattern, '')
                    categories.push c unless @ignore_category_pattern.match c
                end
            end
            if categories.empty?
                result['query']['pages'].each do |pageid, page|
                    links = page['links'].to_a.map do |link|
                        link['title']
                    end
                    categories += look_up_categories links
                end
            end
        else
            logger.error "#{res.class}\n#{res.body}"
        end
        categories
    end

    def lang=(lang)
        config = CONFIG.find { |elm| elm['lang'] === lang }
        raise "lang(#{lang}) is not supported." if config.nil?
        @lang = config['lang']
        @uri = URI("https://#{lang}.wikipedia.org/w/api.php")
        @category_pattern = config['category_pattern']
        @ignore_category_pattern = config['ignore_category_pattern']
    end
end

# client = WikipediaClient.new('ja')
# p client.parse_to_categories(%w/beatles/)
