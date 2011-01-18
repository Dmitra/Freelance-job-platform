class SolutionsController < ApplicationController
  before_filter :login_required, :only => [:new, :create]
  before_filter :check_order_author, :only => [:evaluate]
  
  def index
    @solutions = Solution.search(current_user).paginate(:per_page => self.per_page, :page => params[:page])
  end
  def new
    @solution = Solution.new
  end
  
  def create
    @solution = Solution.new(params[:solution])
    @solution.user = current_user
    @solution.order = Order.find(params[:order_id])
    if @solution.save
      process_file_uploads(@solution)
      redirect_to solution_path(:order_id => params[:order_id], :solution_id => @solution.id)
    else
      render :action => 'new'
    end
  end
  def show
    @solution = Solution.find(params[:id], :include => :order)
  end
  #def edit
    #@solution = Solution.find(params[:id])
  #end
  #def update
    #@solution = Solution.find(params[:id])
    #params[:solution] = {params[:solution][:body], params[:solution][:description]}
    #process_file_uploads(@solution)
    #@solution.update_attributes(params[:solution])
    #render :action => 'show'
  #end
  def evaluate
    @solution = Solution.find(params[:id])
    @solution.evaluate!(current_user, params[:rating].to_i)
    flash[:notice] = "Solution was evaluated"
  end
  def operate
    @solution = Solution.find(params[:id])
    case params[:operation]
      when 'accept'
        @solution.accept!(current_user)
        flash[:notice] = "This order is accomplished"
      when 'refuse'
        @solution.refuse!(current_user)
        flash[:notice] = "This solution was refused"
      when 'restore'
        @solution.restore!(current_user)
        flash[:notice] = "Solution was restored"
      else flash[:notice] = "Operation is not allowed"
    end
    redirect_to order_solution_path(@solution)
  end
  def destroy
    @solutions = params[:id] ? [Solution.find(params[:id])] : Solution.find(params[:solution_ids])
    flash[:notice], flash[:error] = [], []
    @solutions.each{|solution|
      if solution.delete!(current_user)
        flash[:notice] << "Solution #'#{solution.id}' was cancelled"
      else
        flash[:error] << "Access violation. You can't delete solution for accomplished order"
      end
    }
    if params[:solution_ids]
      redirect_to :action => 'solution' 
    else redirect_to order_path(@solutions.last.order)
    end
  end
end
