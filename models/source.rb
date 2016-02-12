class Source
  include DataMapper::Resource

  property :id,          Serial
  property :title,       Text
  property :description, Text
  property :slug,        String, required: true
  property :created_at,  DateTime

  validates_uniqueness_of :slug

  has n, :items
end