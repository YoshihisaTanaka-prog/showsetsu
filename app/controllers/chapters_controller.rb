class ChaptersController < ApplicationController
  before_action :confirm_user_token
  before_action :set_chapter, only: %i[ show edit update destroy ]

  # GET /chapters or /chapters.json
  def index
    respond_to do |format|
      format.html {
        if current_user.title.blank?
          redirect_to titles_path
        else
          @title = Title.find(current_user.title)
          @chapters = @title.chapters
        end
      }
      format.json {
        title = Title.find(params[:title_id])
        if title.user_id == current_user.id
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
    title = @chapter.title_data
    respond_to do |format|
      format.json { render json: {title: title, chapter: @chapter, chapters: title.chapters, stories: @chapter.stories, synopses: @chapter.synopses, characters: @chapter.characters} }
    end
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
    chapter = Chapter.new(chapter_params)
    chapter.title_id = current_user.title
    chapter.user_id = current_user.id
    chapter.save_new_order
    logger.debug chapter.render_json
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render json: chapter.render_json }
    end
  end

  # PATCH/PUT /chapters/1 or /chapters/1.json
  def update
    logger.debug params
    respond_to do |format|
      if @chapter.update(chapter_params)
        format.html { redirect_to chapter_url(@chapter), notice: "Chapter was successfully updated." }
        format.json { render json: @chapter.render_json}
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @chapter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chapters/1 or /chapters/1.json
  def destroy
    @chapter.stories.each do |story|
      story.chapter_id = 0
      story.save
    end
    @chapter.destroy
    session[chapter] = ''
    respond_to do |format|
      format.html { redirect_to chapters_url, notice: "Chapter was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chapter
      @chapter = Chapter.find_by(id: params[:id], user_id: current_user.id)
      if @chapter.blank?
        redirect_to no_page_path
      end
    end

    # Only allow a list of trusted parameters through.
    def chapter_params
      params.require(:chapter).permit(:title)
    end
end
