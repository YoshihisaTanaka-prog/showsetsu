class StoriesController < ApplicationController
  before_action :confirm_user_token
  before_action :set_story, only: %i[ show edit update destroy ]

  # GET /stories or /stories.json
  def index
    @stories = Story.all
  end

  # GET /stories/1 or /stories/1.json
  def show
  end

  # GET /stories/new
  def new
    @story = Story.new
  end

  # GET /stories/1/edit
  def edit
  end

  # POST /stories or /stories.json
  def create
    story = Story.new(story_params)
    story.chapter_id = current_user.chapter
    story.user_id = current_user.id
    story.step_id =current_user.initial_step.id
    story.save_new_order
    story.title_data.set_story_num
    respond_to do |format|
      format.html {
        redirect_to root_path
      }
      format.json {
        render json: story.render_json
      }
    end
  end

  # PATCH/PUT /stories/1 or /stories/1.json
  def update
    respond_to do |format|
      if @story.update(story_params)
        format.html { redirect_to story_url(@story), notice: "Story was successfully updated." }
        format.json { render json: @story.render_json }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/1 or /stories/1.json
  def destroy
    title = @story.title_data
    @story.destroy
    title.set_story_num
    respond_to do |format|
      format.html { redirect_to stories_url, notice: "Story was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_story
      @story = Story.find_by(id: params[:id], user_id: current_user.id)
      if @story.blank?
        redirect_to no_page_path
      end
    end

    # Only allow a list of trusted parameters through.
    def story_params
      params.require(:story).permit(:title, :body)
    end
end
