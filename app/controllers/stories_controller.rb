class StoriesController < ApplicationController
  before_action :authenticate_user!
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
    respond_to do |format|
      format.html {
        story = Story.new(story_params)
        story.chapter_id = session[:chapter]
        story.user_id = current_user.id
        story.step_id =current_user.initial_step.id
        story.save_new_order
        story.set_token
        new_token 'story'
        redirect_to root_path
      }
      format.json {
        story = Story.new
        story.title = params[:title]
        story.body = params[:body]
        story.chapter_id = session[:chapter]
        story.user_id = current_user.id
        story.step_id =current_user.initial_step.id
        story.save_new_order
        story.set_token
        new_token 'story'
        render json: {id: step.id, :token => session[:step_token]}
      }
    end
  end

  # PATCH/PUT /stories/1 or /stories/1.json
  def update
    respond_to do |format|
      if @story.update(story_params)
        format.html { redirect_to story_url(@story), notice: "Story was successfully updated." }
        format.json { render :show, status: :ok, location: @story }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/1 or /stories/1.json
  def destroy
    @story.destroy

    respond_to do |format|
      format.html { redirect_to stories_url, notice: "Story was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_story
      @story = Story.find(params[:id])
      unless @story.user_id == current_user.id
        redirect_to stories_path
      end
    end

    # Only allow a list of trusted parameters through.
    def story_params
      params.require(:story).permit(:title, :body)
    end
end
