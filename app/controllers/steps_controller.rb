class StepsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_step, only: %i[ show edit update destroy ]

  # GET /steps or /steps.json
  def index
    @steps = current_user.steps
  end

  # GET /steps/1 or /steps/1.json
  def show
  end

  # GET /steps/new
  def new
    @step = Step.new
  end

  # GET /steps/1/edit
  def edit
  end

  # POST /steps or /steps.json
  def create
    step = Step.new(step_params)
    step.user_id = current_user.id
    step.save_new_order
    respond_to do |format|
      format.json { render json: step.render_json }
    end
  end

  # PATCH/PUT /steps/1 or /steps/1.json
  def update
    respond_to do |format|
      if @step.update(step_params)
        format.html { redirect_to steps_path, notice: "Step was successfully updated." }
        format.json { render json: @step.render_json }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @step.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /steps/1 or /steps/1.json
  def destroy
    @step.destroy

    respond_to do |format|
      format.html { redirect_to steps_url, notice: "Step was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def sort
    i_step = Step.find_by(id: params[:iid])
    j_step = Step.find_by(id: params[:jid])

    unless i_step.nil? || j_step.nil?
      if i_step.user_id == j_step.user_id && current_user.id == i_step.user_id
        keep = i_step.order
        i_step.order = j_step.order
        j_step.order = keep
        i_step.save
        j_step.save
      end
    end
    redirect_to steps_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_step
      @step = Step.find(params[:id])
      unless @step.user_id == current_user.id
        redirect_to root_path
      end
    end

    # Only allow a list of trusted parameters through.
    def step_params
      params.require(:step).permit(:name)
    end
end
