class Source
  include DataMapper::Resource

  property :id,          Serial
  property :title,       Text
  property :description, Text
  property :slug,        String, required: true
  property :created_at,  DateTime

  has n, :items
end