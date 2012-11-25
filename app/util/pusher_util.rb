require 'pusher'

Pusher.app_id = '29060'
Pusher.key = '51534d8ca2640c342dba'
Pusher.secret = '495026b1c43c7073c28c'

class PusherUtil

  def self.push(channel, event, msg)
    Pusher[channel].trigger event, {:message => msg}
  end


end