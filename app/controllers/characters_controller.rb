class CharactersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_character, only: %i[ show edit update destroy ]

  # GET /characters or /characters.json
  def index
    respond_to do |format|
      format.html {
        if session[:title].blank?
          redirect_to root_path
        else
          @characters = Character.where(user_id: current_user.id, title_id: session[:title]).order(:order)
        end
      }
      format.json {
        chapter = Chapter.find(params[:chapter_id])
        render :json => chapter.characters
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
    @character = Character.new(character_params)
    @character.user_id = current_user.id
    respond_to do |format|
      if @character.save
        @character.order = @character.id
        if @character.save
          format.html { redirect_to root_path }
          format.json { render :show, status: :created, location: @character }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @character.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @character.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /characters/1 or /characters/1.json
  def update
    respond_to do |format|
      if @character.update(character_params)
        format.html { redirect_to root_path }
        format.json { render :show, status: :ok, location: @character }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @character.errors, status: :unprocessable_entity }
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
      @character = Character.find(params[:id])
      unless @character.user_id == current_user.id
        redirect_to root_path
      end
    end

    # Only allow a list of trusted parameters through.
    def character_params
      params.require(:character).permit(:name, :comment)
    end
end
