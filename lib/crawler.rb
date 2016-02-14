#!/usr/bin/env ruby
# require_relative File.join('config', 'application.rb')

# sources = YamlData.get_hash_file('sources.yml')
class Crawler
  def initialize(source_key)
    @key = source_key
    @config = sources[source_key]
    raise 'Source not found' unless @config
    @slug = @config[:slug] || source_key
    @title = @config[:title]

    @source = Source.first_or_create(slug: @slug)
    update_source if @source.title.nil? && @source.description.nil?

    @description = @config[:description]
    @browser = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
    end
  end

  def posts_list
    scanned = []
    list = []
    pull = pages_list
    puts "Updade posts list"
    while pull.size > 0
      curr = pull.shift
      continue if scanned.include? curr
      @browser.get(curr) do |page|
        puts "scaning #{curr} for posts"
        filtered = page.links.map{|l| l && l.href}.select() do |l|
          @config[:posts].select{ |r| /#{r}/i =~ l }.size > 0 
        end
        list += filtered
        list.uniq!
      end
      scanned << curr
    end
    list
  end

  def pages_list
    scanned = []
    list = []
    pull = @config[:points].dup()
    puts "Updade pages list"
    while pull.size > 0
      curr = pull.shift
      continue if scanned.include? curr
      @browser.get(curr) do |page|
        puts "scaning #{curr} for pages"
        filtered = page.links.map{|l| l && l.href}.select() do |l|
          @config[:pages].select{ |r| /#{r}/i =~ l }.size > 0 
        end
        list += filtered
        pull += filtered
        list.uniq!
      end
      scanned << curr
    end
    list
  end

  def search_for(page, find, &block)
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

  def items_list
    items = []
    posts = posts_list

    posts.each_with_index do |post, index|
      # puts "Scaning page [#{post}] for content"
      @browser.get(post) do |page|
        title = search_for(page, @config[:details][:title]).text
        content = search_for(page, @config[:details][:content]).to_html

        files = search_for(page, @config[:details][:file]).map { |l| l.attr(:href) }

        date = search_for(page, @config[:details][:date]).text
        version = search_for(page, @config[:details][:version]).map(&:text).map(&:to_i)

        puts "#{index+1}/#{posts.size} > Item [#{files.size} files] at #{date}: #{title[0..50]}..."
        item = {
          title: title,
          content: content,
          files: files,
          date: date,
          origin: post,
          version: version
        }
        apply_item item
      end
    end
    items
  end

  def sources
    @sources ||= YamlData.get_hash_file(File.join(App.root, 'config', 'sources.yml'))
  end

  def update_source
    @source.update(
      title: @config[:title],
      description: @config[:description]
    )
  end

  def apply_item(remote)
    item = Item.first(
      origin: remote[:origin])
    if item
      if item.changed?(remote) && item.update_from_remote(remote)
        @updated << item.id
      end
    else
      item = Item.create_from_remote remote, @source
      @added << item.id if item.saved?
    end
  end

  def update_items
    items = Item.all(source: @source)
    @updated = []
    @added = []

    remote_items = items_list

    puts "Added #{@added.size} items"
    puts "Updated #{@updated.size} items"
  end

end

# c = Crawler.new(:rwpod)
# list = c.update_items

# YamlData.put_hash_file File.join(File.dirname(__FILE__), 'out', 'dst.yml'), list