class UsersController < ApplicationController

  layout 'apps'
  before_filter :admin_required, :except => :waitlist

  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json {

        pagination_state = update_pagination_state_with_params!(:app)
        @users = User.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(:app)))

        render :json => @users.to_ext_json(:class => :user, 
                              :count => User.count, 
                              :ar_options => {:only => [:login, :email, :created_at, :id, ],
                                             }
                        )
      }
    end
  end

  # render new.rhtml
  def new
  end

  # render new.rhtml
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  def create
    #cookies.delete :auth_token
    ## protects against session fixation attacks, wreaks havoc with 
    ## request forgery protection.
    ## uncomment at your own risk
    ## reset_session
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      #self.current_user = @user
      #redirect_back_or_default('/')
      flash[:notice] = 'User was successfully created.'
      redirect_to users_path
    else
      render :action => 'new'
    end
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to users_path
    else
      render :action => 'edit'
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end

end
