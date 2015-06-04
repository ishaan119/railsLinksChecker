class CheckLinksController < ApplicationController
  before_action :set_check_link, only: [:show, :edit, :update, :destroy]

  # GET /check_links
  # GET /check_links.json
  def index
    @check_links = CheckLink.all
  end

  # GET /check_links/1
  # GET /check_links/1.json
  def show
  end

  # GET /check_links/new
  def new
    puts 'In nes'
    @check_link = CheckLink.new()
  end

  # GET /check_links/1/edit
  def edit
  end

  # POST /check_links
  # POST /check_links.json
  def create
    @check_link = CheckLink.new()

    @check_link.get_all_links(check_link_params['checked_url']).class

    respond_to do |format|
      if @check_link.save
        format.html { redirect_to @check_link, notice: 'Check link was successfully created.' }
        format.json { render :show, status: :created, location: @check_link }
      else
        format.html { render :new }
        format.json { render json: @check_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /check_links/1
  # PATCH/PUT /check_links/1.json
  def update
    respond_to do |format|
      if @check_link.update(check_link_params)
        format.html { redirect_to @check_link, notice: 'Check link was successfully updated.' }
        format.json { render :show, status: :ok, location: @check_link }
      else
        format.html { render :edit }
        format.json { render json: @check_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /check_links/1
  # DELETE /check_links/1.json
  def destroy
    @check_link.destroy
    respond_to do |format|
      format.html { redirect_to check_links_url, notice: 'Check link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_check_link
      @check_link = CheckLink.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def check_link_params
      params.require(:check_link).permit(:checked_url, :errors_found)
    end
end
