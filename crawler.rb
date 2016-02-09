#!/usr/bin/env ruby
require 'mechanize'
require_relative 'yaml_data'

# data:
#   urls:
#     pages: ['', '', '']
#     posts: ['', '', '']
#   items:
#     title: ""
#     content: ""
#     urls: [""]

# sources = YamlData.get_hash_file('sources.yml')
class Crawler
  @@root = File.dirname(__FILE__)

  def self.get_source(key)
    source = YamlData.get_hash_file(File.join(@@root, 'sources.yml'))[key]
    raise "Ooops... Source not found..." if source.nil?
    source
  end

  def self.get_data(key)
    data = YamlData.get_hash_file(File.join(@@root, 'out', "#{key}.yml")) ||
    puts('Ooops... Data not found...') if data.nil?
    data ||= { urls: { pages: [], posts: [] }, items: [] }
    data
  end

  def initialize(source_key)
    @key = source_key
    @source = Crawler.get_source(source_key)
    @data = Crawler.get_data(source_key)
    @browser = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
    end
  end

  def get_posts_list
    scanned = []
    list = []
    pull = get_pages_list
    puts "Updade posts list"
    while pull.size > 0
      curr = pull.shift
      continue if scanned.include? curr
      @browser.get(curr) do |page|
        puts "scaning #{curr} for posts"
        filtered = page.links.map{|l| l && l.href}.select() do |l|
          @source[:posts].select{ |r| /#{r}/i =~ l }.size > 0 
        end
        list += filtered
        list.uniq!
      end
      scanned << curr
    end
    list
  end

  def get_pages_list
    scanned = []
    list = []
    pull = @source[:points].dup()
    puts "Updade pages list"
    while pull.size > 0
      curr = pull.shift
      continue if scanned.include? curr
      @browser.get(curr) do |page|
        puts "scaning #{curr} for pages"
        filtered = page.links.map{|l| l && l.href}.select() do |l|
          @source[:pages].select{ |r| /#{r}/i =~ l }.size > 0 
        end
        list += filtered
        pull += filtered
        list.uniq!
      end
      scanned << curr
    end
    list
  end


  def search_for page, find, &block
    case find
    when String
      items = page.search(find)
      items = block.call(items) if block_given?
    when Hash
      # find, regex
      if find[:find].nil? || find[:find].empty?
        items = page.search("html")
      else
        items = page.search(find[:find])
      end
      items = block.call(items) if block_given?
      unless find[:regex].nil? || find[:regex].empty?
        items = items.map do |i|
          match = i.to_s.scan(/#{find[:regex]}/)
            .map {|i| i.is_a?(Array)? i.last : i}.join(' ')
        end
        items = Nokogiri::HTML(items.join(' ')).search('body').children
      end
    when Array
      items = nil
      find.each do |f|
        ff = search_for(page, f, &block)
        unless items
          items = ff
        else
          items += ff
        end
      end
    else
      items = page
    end
    items
  end

  def get_items_list
    items = []
    posts = get_posts_list


    posts.each do |post|
      puts "Scaning page [#{post}] for content"
      @browser.get(post) do |page|
        title = search_for(page, @source[:details][:title]).text
        content = search_for(page, @source[:details][:content]).to_html

        files = search_for(page, @source[:details][:file]).map { |l| l.attr(:href) }

        date = search_for(page, @source[:details][:date]).text
        version = search_for(page, @source[:details][:version]).map(&:text).map(&:to_i)

        puts "#{version} on #{date}"
        puts "Loaded[#{files.size} files]: #{title}"
        items << {
          title: title,
          content: content,
          files: files,
          date: date,
          version: version
        }
      end
    end
    items
  end
end

c = Crawler.new(:rwpod)
list = c.get_items_list

YamlData.put_hash_file File.join(File.dirname(__FILE__), 'out', 'dst.yml'), list