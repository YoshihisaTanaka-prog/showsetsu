class TitlesController < ApplicationController
  before_action :confirm_user_token
  before_action :set_title, only: %i[ show edit update destroy ]

  # GET /titles or /titles.json
  def index
    @titles = current_user.titles
    respond_to do |format|
      format.html
      format.json {
        render json: {data: @titles}
      }
    end
    @title = Title.new
  end

  # GET /titles/1 or /titles/1.json
  def show
    redirect_to chapters_path
  end

  # GET /titles/new
  def new
    @title = Title.new
  end

  # GET /titles/1/edit
  def edit
  end

  # POST /titles or /titles.json
  def create
    logger.debug params
    logger.debug request.url
    title = Title.new(title_params)
    title.user_id = current_user.id
    title.save
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render json: title.render_json }
    end
  end

  # PATCH/PUT /titles/1 or /titles/1.json
  def update
    logger.debug title_params
    respond_to do |format|
      if @title.update(title_params)
        format.html { redirect_to root_path }
        format.json { render json: @title.render_json }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @title.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /titles/1 or /titles/1.json
  def destroy
    @title.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_title
      @title = Title.find_by(id: params[:id], user_id: current_user.id)
      if @title.blank?
        redirect_to no_page_path
      end
    end

    # Only allow a list of trusted parameters through.
    def title_params
      params.require(:title).permit(:title)
    end
end
