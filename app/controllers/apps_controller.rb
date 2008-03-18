class AppsController < ApplicationController

  before_filter :login_required, :except => :waitlist
  before_filter :find_app, :only => [ :show, :edit, :update, :destroy ]

  # GET /apps
  # GET /apps.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json {
        find_apps
        render :json => @apps.to_ext_json(:class => :app, 
                              :count => App.count, 
                              :ar_options => {:only => [:status, :first_name, :last_name, :wait_list_position, :id, :code ],
                                              :methods => [:txt_status, :txt_current_grade, :txt_type] }
                        )
      }
    end
  end

  # GET /wait_editor
  # This allows the user to change the order of the waitlist via ajax
  def wait_editor
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { 
        query = params[:query] || 'k'
        @apps = App.wait_list_for_txt_grade(query)
        render :json => @apps.to_ext_json(:class => :app, 
                              :count => @apps.length, 
                              :ar_options => {:only => [:status, :first_name, :last_name, :wait_list_position, :id, :code ],
                                              :methods => [:txt_status, :txt_current_grade, :txt_type] } ) }
    end
  end

  # GET /update_order
  # Take an ajax wait_editor reordering and store that in the database
  def update_order
    obj_id  = params[:obj_id]
    new_pos = params[:new_pos].to_i
    query   = params[:query]
    obj = App.find obj_id

    # Ok, one of the Apps has just moved, 
    @apps = App.wait_list_for_txt_grade(query)
    @apps.delete obj
    old_pos = obj.wait_list_position
    obj.wait_list_position = new_pos
    obj.save

    if (new_pos < old_pos)
      @apps.reject! { |e| (e.wait_list_position < new_pos) || (e.wait_list_position > old_pos) }
      @apps.each do 
        | e |
          e.wait_list_position += 1 
        e.save
      end
    else
      @apps.reject! { |e| (e.wait_list_position > new_pos) || (e.wait_list_position < old_pos) }
      @apps.each do 
        | e |
          e.wait_list_position -= 1 
        e.save
      end
    end

    render :update do |page| 
      page.replace_html('flash-message', "Did re-order event #{obj.code} new pos -> #{new_pos}")
      page.show 'flash-message' 
      page.visual_effect :highlight, 'flash-message' 
      page.call('app_datastore.reload')
      page.delay(4) do
        page.visual_effect :fade, 'flash-message' 
      end
    end 
  end

  # GET /waitlist
  def waitlist
    @apps = App.wait_list

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
