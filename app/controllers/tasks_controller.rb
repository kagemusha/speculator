class TasksController < ApplicationController

  def stock_scrape
    StockScrapeWorker.perform_async 'screpy', 5
    redirect_to tasks_url
  end

  def test_task
    TestWorker.perform_async "hello", 5
    #TestTask.create_file "dir"
    redirect_to tasks_url
  end
end
