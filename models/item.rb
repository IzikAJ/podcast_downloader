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
  has n, :file_items

  def like_remote? remote
    remote[:title] == title &&
      remote[:origin] == origin

  def not_updated? remote
    remote[:title] == title &&
      remote[:content] == content &&
      remote[:files] == files.map(&:url)
  end
end