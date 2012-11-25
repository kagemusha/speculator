class StockScrapeWorker
  include Sidekiq::Worker

  def perform(name, count)
    Util.p "performing STOCKSCREPer"
    NewLowScraper.do
  end

end