class AppsController < ApplicationController

  before_filter :login_required, :except => :waitlist
  before_filter :find_app, :only => [ :show, :edit, :update, :destroy ]

  # GET /apps
  # GET /apps.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json =>
        find_apps.to_ext_json(:class => :app, 
                              :count => App.count, 
                              :ar_options => {:only => [:status, :first_name, :last_name, :wait_list_position, :id, :code ],
                                              :methods => [:txt_status, :txt_current_grade, :txt_type] } ) }
    end
  end

  # GET /waitlist
  def waitlist
    apps0 = App.find :all

    apps1 = apps0.reject { |e| e.txt_status == 'removed' }
    apps2 = apps1.reject { |e| e.wait_list_position == 0 }

    apps = {}
    (0..8).each do | grade |
      apps[grade] = apps2.select { |e| e.current_grade == grade }.sort_by { |a| a.wait_list_position }
    end

    @apps = apps

    respond_to do |format|
      format.html {    # index.html.erb (no data required)
          render :layout => "waitlist"
      }
    end
  end

  # GET /apps/1
  def show
    # show.html.erb
  end

  # GET /apps/new
  def new
    @app = App.new(params[:app])
    @app.state = "CA"
    @app.grade_in_year = App.this_year
    @app.grade = 0
  end

  # GET /apps/1/edit
  def edit
    # edit.html.erb
  end

  # POST /apps
  def create
    App.grade_from_params(params[:app]) # txform current_grade to real fields

    @app = App.new(params[:app])

    respond_to do |format|
      if @app.save
        flash[:notice] = 'App was successfully created.'
        format.ext_json { render(:update) {|page| page.redirect_to apps_url } }
      else
        format.ext_json { render :json => @app.to_ext_json(:success => false) }
      end
    end
  end

  # PUT /apps/1
  def update

    App.grade_from_params(params[:app]) # txform current_grade to real fields

    respond_to do |format|
      if @app.update_attributes(params[:app])
        flash[:notice] = 'App was successfully updated.'
        format.ext_json { render(:update) {|page| page.redirect_to apps_url } }
      else
        format.ext_json { render :json => @app.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /apps/1
  def destroy
    @app.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
    def find_app
      @app = App.find(params[:id])
    end
    
    def find_apps
      pagination_state = update_pagination_state_with_params!(:app)
      @apps = App.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(:app)))
    end

end
