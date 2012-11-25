class TestWorker
  include Sidekiq::Worker

  def perform(name, count)
    TestTask.create_file "testWorker"
  end

end
