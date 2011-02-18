class AppsController < ApplicationController

  before_filter :login_required, :except => :waitlist
  before_filter :find_app, :only => [ :show, :edit, :update, :destroy, :toggle_zero, :update_order ]

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
        @apps = App.wait_list_for_txt_grade(query, true)
        render :json => @apps.to_ext_json(:class => :app, 
                              :count => @apps.length, 
                              :ar_options => {:only => [:status, :first_name, :last_name, :wait_list_position, :id, :code ],
                                              :methods => [:txt_status, :txt_current_grade, :txt_type] } ) }
    end
  end

  # GET /update_order
  # Take an ajax wait_editor reordering and store that in the database
  def update_order
    new_pos = params[:new_pos].to_i

    old_pos = @app.wait_list_position

    if old_pos != 0

      # Now check that the new_pos is not in the zero wait-list
      @apps = App.wait_list_for_txt_grade(@app.txt_current_grade, true)
      new_pos = @apps[new_pos].wait_list_position

      if new_pos == 0
        mesg = "Can not move. App is in non-zero wait-list."
      else

        # Ok, first, lets get rid of the zero wait-list
        @apps.reject! { |e| e.wait_list_position == 0 }

        # Remove this app from the list, but give it the new position
        @apps.delete @app
        @app.wait_list_position = new_pos
        @app.save

        if (new_pos < old_pos)             # App moved up
          @apps.reject! { |e| (e.wait_list_position < new_pos) || (e.wait_list_position > old_pos) }
          @apps.each do 
            | e |
              e.wait_list_position += 1 
            e.save
          end
        else                               # App moved down
          @apps.reject! { |e| (e.wait_list_position > new_pos) || (e.wait_list_position < old_pos) }
          @apps.each do 
            | e |
              e.wait_list_position -= 1 
            e.save
          end
        end
        mesg = "Did re-order event #{@app.code} new pos -> #{new_pos}"
      end
    else
      mesg = "Did not move. App is zero in wait-list."
    end

    render :update do |page| 
      page.replace_html('flash-message', mesg)
      page.show 'flash-message' 
      page.visual_effect :highlight, 'flash-message' 
      page.call('app_datastore.reload')
      page.delay(4) do
        page.visual_effect :fade, 'flash-message' 
      end
    end 
  end

  # GET /toggle_zero
  # Take an ajax wait_editor request to toggle a user between zero and non-zero in the wait_list_position
  def toggle_zero

    if (@app.wait_list_position == 0)
      @app.move_to_end_of_waitlist
      mesg = 'Moved to end of waitlist'
    else
      @app.wait_list_position = 0
      @app.save
      mesg = 'Moved to zero group'
    end

    r = App.normalize_waitlist_for_txt_grade(@app.txt_current_grade)

    render :update do |page| 
      page.replace_html('flash-message', mesg)
      page.show 'flash-message' 
      page.visual_effect :highlight, 'flash-message' 
      page.call('app_datastore.reload')
      page.delay(4) do
        page.visual_effect :fade, 'flash-message' 
      end
    end 
  end

  # GET /ungap_list
  # Normalize the order of the wait_list
  def ungap_list

    grade = params[:current_grade]
    r = App.normalize_waitlist_for_txt_grade(grade)

    if r == 1
      mesg = 'Adjusted list'
    elsif r == 0
      mesg = 'Nothing to do'
    else
      mesg = 'Error adjusting list'
    end

    render :update do |page| 
      page.replace_html('flash-message', mesg)
      page.show 'flash-message' 
      page.visual_effect :highlight, 'flash-message' 
      if (r == 1)
        page.call('app_datastore.reload')
      end
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
  
  # GET /apps/bulk_add
  def bulk_add
    # bulk_add.html.erb
  end

  # POST /apps/upload
  def upload
    require 'fastercsv'
    p params
    p params[:upload][:datafile].class
    if params[:upload][:datafile] == ""
      flash.now[:notice] = 'Invalid file for bulk_add.'
      render :action => 'bulk_add'
      return
    end
    p params[:upload][:datafile]
    result = App.import_from_csv(params[:upload][:datafile])
    if result[0] == 'fail'
      flash.now[:notice] = "Error: #{result[1]}"
      render :action => 'bulk_add'
      return
    end
    # bulk_add.html.erb
    redirect_to '/apps/bulk_view'
  end

  # GET /apps/bulk_view
  def bulk_view
    # bulk_view.html.erb
    @data = Bulk.find :all
  end


  # GET /apps/commit
  def commit
    # bulk_add.html.erb
    p params
    if params["commit"]
      if params["commit"] == "Import"
        @data = Bulk.find :all
        @data.each {
          |b|
          a = App.new(b.attributes)
          a.wait_list_position = 0
          a.save!
        }
        Bulk.destroy_all
        flash[:notice] = "Added #{@data.length} records"
        return redirect_to '/apps'
      end
      if params["commit"] == "CANCEL"
        Bulk.destroy_all
        flash[:notice] = "Cancelled Import"
        return redirect_to '/apps/bulk_add'
      end
    end
    redirect_to '/apps/bulk_view'
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
