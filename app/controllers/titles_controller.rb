class TitlesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_title, only: %i[ show edit update destroy ]

  # GET /titles or /titles.json
  def index
    @titles = current_user.titles
    session[:title] = ''
    respond_to do |format|
      format.html
      format.json {
        new_token 'title'
        render json: {data: @titles, :token => session[:title_token]}
      }
    end
    @title = Title.new
  end

  # GET /titles/1 or /titles/1.json
  def show
    session[:title] = @title.id
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
    respond_to do |format|
      format.html {
        title = Title.new(title_params)
        title.user_id = current_user.id
        title.set_token
        new_token 'title'
        session[:title] = title.id
        redirect_to root_path
      }
      format.json {
        protect_from_forgery
        title = Title.new
        title.title = params[:title]
        title.user_id = current_user.id
        title.set_token
        render json: {id: title.id}
      }
    end
  end

  # PATCH/PUT /titles/1 or /titles/1.json
  def update
    session[:title] = @title.id
    respond_to do |format|
      if @title.update(title_params)
        format.html { redirect_to root_path }
        format.json { render :show, status: :ok, location: @title }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @title.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /titles/1 or /titles/1.json
  def destroy
    session[:title] = ''
    @title.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_title
      @title = Title.find(params[:id])
      unless @title.user_id == current_user.id
        redirect_to titles_path
      end
    end

    # Only allow a list of trusted parameters through.
    def title_params
      params.require(:title).permit(:title)
    end
end
