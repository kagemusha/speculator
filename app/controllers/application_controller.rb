require 'pusher'

Pusher.app_id = '29060'
Pusher.key = '51534d8ca2640c342dba'
Pusher.secret = '495026b1c43c7073c28c'

class ApplicationController < ActionController::Base
  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end
  helper :all

end
