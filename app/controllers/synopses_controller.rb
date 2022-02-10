class SynopsesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_synopsis, only: %i[ show edit update destroy ]

  # GET /synopses or /synopses.json
  def index
    respond_to do |format|
      format.html {
        if current_user.title.blank?
          redirect_to root_path
        else
          @synopses = Synopsis.where(user_id: current_user.id, title_id: current_user.title).order(:order)
        end
      }
      format.json {
        chapter = Chapter.find(params[:chapter_id])
        render :json => chapter.synopses
      }
    end
  end

  # GET /synopses/1 or /synopses/1.json
  def show
  end

  # GET /synopses/new
  def new
    @synopsis = Synopsis.new
  end

  # GET /synopses/1/edit
  def edit
  end

  # POST /synopses or /synopses.json
  def create
    respond_to do |format|
      synopsis = Synopsis.new(synopsis_params)
      synopsis.user_id = current_user.id
      synopsis.title_id = current_user.:title
      synopsis.save_new_order
      format.html { redirect_to root_path }
      format.json { render json: synopsis.render_json }
    end
  end

  # PATCH/PUT /synopses/1 or /synopses/1.json
  def update
    respond_to do |format|
      if @synopsis.update(synopsis_params)
        format.html { redirect_to root_path }
        format.json { render json: @synopsis.render_json }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @synopsis.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /synopses/1 or /synopses/1.json
  def destroy
    @synopsis.destroy

    respond_to do |format|
      format.html { redirect_to synopses_url, notice: "Synopsis was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_synopsis
      @synopsis = Synopsis.find(params[:id])
      unless @synopsis.user_id == current_user.id
        redirect_to root_path
      end
    end

    # Only allow a list of trusted parameters through.
    def synopsis_params
      params.require(:synopsis).permit(:comment)
    end
end
