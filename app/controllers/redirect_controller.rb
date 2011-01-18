class RedirectController < ApplicationController
  def index
    params[:search] = params[:path].first
    redirect_to "/orders?search=#{params[:path].first}"
  end
end