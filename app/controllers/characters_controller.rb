class CharactersController < ApplicationController
  before_action :confirm_user_token
  before_action :set_character, only: %i[ show edit update destroy ]

  # GET /characters or /characters.json
  def index
    respond_to do |format|
      format.html {
        if current_user.title.blank?
          redirect_to root_path
        else
          @characters = Character.where(user_id: current_user.id, title_id: current_user.title).order(:order)
        end
      }
      format.json {
        chapter = Chapter.find(params[:chapter_id])
        render :json => {title: chapter.title_data, chapter: chapter, stories: chapter.stories}
      }
    end
  end

  # GET /characters/1 or /characters/1.json
  def show
  end

  # GET /characters/new
  def new
    @character = Character.new
  end

  # GET /characters/1/edit
  def edit
  end

  # POST /characters or /characters.json
  def create
    respond_to do |format|
      character = Character.new(character_params)
      character.title_id = current_user.title
      character.user_id = current_user.id
      character.save_new_order
      format.html { redirect_to root_path }
      format.json { render json: character.render_json }
    end
  end

  # PATCH/PUT /characters/1 or /characters/1.json
  def update
    respond_to do |format|
      if @character.update(character_params)
        format.html { redirect_to root_path }
        format.json { render jsoncharacter.render_json }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: character.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /characters/1 or /characters/1.json
  def destroy
    @character.destroy

    respond_to do |format|
      format.html { redirect_to characters_url, notice: "Character was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_character
      @character = Character.find_by(id: params[:id], user_id: current_user.id)
      if @character.blank?
        redirect_to no_page_path
      end
    end

    # Only allow a list of trusted parameters through.
    def character_params
      params.require(:character).permit(:name, :comment)
    end
end
