class Note
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :stock

  field :title, type: String
  field :content, type: String

end
