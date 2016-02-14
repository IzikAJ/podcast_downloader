class Item
  include DataMapper::Resource

  property :id,           Serial
  property :source_id,    Integer, required: true
  property :title,        Text
  property :description,  Text
  property :content,      Text
  property :version,      String
  property :origin,       String, required: true
  property :published_at, DateTime
  property :created_at,   DateTime

  belongs_to :source
  has n, :file_items, constraint: :destroy

  def self.create_from_remote remote, source
    item = create(
      source: source,
      origin: remote[:origin]
    )
    item if item.valid? && item.update_from_remote(remote)
  end

  def download
    loaded = file_items.map(&:downloaded?)
  end

  def update_from_remote remote
    urls = remote[:files] - file_items.map(&:url).map(&:to_s)
    urls.each do |url|
      FileItem.create( item_id: id, url: url )
    end
    
    update(
      title: remote[:title],
      description: Nokogiri::HTML(remote[:content]).text,
      content: remote[:content],
      version: remote[:version].join('.'),
      published_at: DateTime.parse(remote[:date])
    )
  end

  def like_remote? remote
    remote[:title] == title &&
      remote[:origin] == origin
  end
  def changed? remote
    !(remote[:title] == title &&
      remote[:content] == content &&
      remote[:files] == file_items.map(&:url).map(&:to_s))
  end
end