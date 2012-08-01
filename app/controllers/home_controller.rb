class HomeController < ApplicationController
  def index
    Util.p "michael"
    @users = User.all
  end
end
