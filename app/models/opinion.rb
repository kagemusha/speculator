class Opinion
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :stock

  field :action, type: String
  field :killer, type: String
  field :catalyst, type: String #generally pos
  field :sales_comments, type: String
  field :pl_comments, type: String
  field :bs_comments, type: String
  field :cf_comments, type: String
  field :credit_rating, type: String
  field :general_comments, type: String

  ACTIONS = ["Review Next Quarter","Review in 2Q","No interest", "Not Shortable",
  "Of interest", "Exploratory Short","Short", "Strong Short!","Buy"]

  def no_current_interest
    ["Review Next Quarter","Review in 2Q","No interest", "Not Shortable"].include? action
  end
end
