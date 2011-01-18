class AssetsController < ApplicationController
  
  def show
    asset = Asset.find(params[:id])
    # do security check here
    send_file asset.data.path, :type => asset.data_content_type, :disposition => 'asset', :x_sendfile => true
  end
  def destroy
    @edit = true if params[:edit]
    @asset = Asset.find(params[:id])
    @asset.destroy
  end

end
