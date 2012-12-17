class Link
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :stock

  field :title, type: String
  field :url, type: String
end
