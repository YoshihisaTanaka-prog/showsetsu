class StepsController < ApplicationController
  # before_action :confirm_user_token
  # before_action :authenticate_user!
  before_action :set_step, only: %i[ show edit update destroy ]

  # GET /steps or /steps.json
  def index
    @user = User.find(params[:user_id])
    @steps = @user.steps
  end

  # GET /steps/1 or /steps/1.json
  def show
  end

  # GET /steps/new
  def new
    @step = Step.new
    st = get_session
    st.set_log ({step: 0})
  end

  # GET /steps/1/edit
  def edit
    st = get_session
    st.set_log ({step: params[:id]})
  end

  # POST /steps or /steps.json
  def create
    logger.debug params
    step = Step.new(step_params)
    step.user_id = params[:user_id]
    step.save_new_order
    st = get_session
    st.set_log ({step: -1})
    index
    render action: 'index'
  end

  # PATCH/PUT /steps/1 or /steps/1.json
  def update
    if @step.update(step_params)
      st = get_session
      st.set_log ({step: -1})
      index
      render action: 'index'
    end
  end

  # DELETE /steps/1 or /steps/1.json
  def destroy
    @step.destroy
    st = get_session
    st.set_log ({step: -1})
    index
    render action: 'index'
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
      # @step = Step.find_by(id: params[:id], user_id: current_user.id)
      @user = User.find_by_id(params[:user_id])
      unless @user.nil?
        @step = Step.find_by(id: params[:id], user_id: @user.id)
        if @step.blank?
          redirect_to no_page_path
        end
      end
    end

    # Only allow a list of trusted parameters through.
    def step_params
      params.require(:step).permit(:name)
    end
end
