class ChaptersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter, only: %i[ show edit update destroy ]

  # GET /chapters or /chapters.json
  def index
    respond_to do |format|
      format.html {
        if session[:title].blank?
          redirect_to titles_path
        else
          @title = Title.find(session[:title])
          @chapters = @title.chapters
        end
      }
      format.json {
        title = Title.find(params[:title_id])
        if title.user_id == current_user.id
          session[:title] = title.id
          chapters = title.chapters
          render :json => {:title => title, :chapters => chapters}
        else
          render :json => {}
        end
      }
    end
  end

  # GET /chapters/1 or /chapters/1.json
  def show
  end

  # GET /chapters/new
  def new
    @chapter = Chapter.new
    set_new_token
  end

  # GET /chapters/1/edit
  def edit
  end

  # POST /chapters or /chapters.json
  def create
    respond_to do |format|
      format.html {
        chapter = Chapter.new(chapter_params)
        chapter.title_id = session[:title]
        chapter.user_id = current_user.id
        chapter.save_new_order
        chapter.set_token
        new_token 'chapter'
        redirect_to root_path
      }
      format.json {
        if params[:token] == session[:chapter_token]
          chapter = Chapter.new
          chapter.title = params[:title_id]
          chapter.title_id = session[:title]
          chapter.user_id = current_user.id
          chapter.save_new_order
          chapter.set_token
          new_token 'chapter'
          render json: {:id => chapter.id, :token => session[:chapter_token]}
        end
      }
    end
  end

  # PATCH/PUT /chapters/1 or /chapters/1.json
  def update
    respond_to do |format|
      if @chapter.update(chapter_params)
        format.html { redirect_to chapter_url(@chapter), notice: "Chapter was successfully updated." }
        format.json { render :show, status: :ok, location: @chapter }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @chapter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chapters/1 or /chapters/1.json
  def destroy
    @chapter.destroy

    respond_to do |format|
      format.html { redirect_to chapters_url, notice: "Chapter was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chapter
      @chapter = Chapter.find(params[:id])
      unless @chapter.user_id == current_user.id
        redirect_to chapters_path
      end
    end

    # Only allow a list of trusted parameters through.
    def chapter_params
      params.require(:chapter).permit(:title)
    end
end