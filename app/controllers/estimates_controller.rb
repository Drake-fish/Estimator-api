class EstimatesController < ApplicationController
  before_action :set_project
  before_action :set_project_estimate, only: [:show, :update, :destroy]

  def index
    json_response(@project.estimates)
  end

  def show
    json_response(@estimate)
  end

  def create
    estimate = @project.estimates.new(estimate_params)
    if estimate.save
      json_response(estimate, :created)
    else
      json_response({status:422, message: estimate.errors.full_messages })
    end
  end

  def update
    @estimate.update(estimate_params)
    head :no_content
  end

  def destroy
    @estimate.destroy
    head :no_content
  end


  private

  def estimate_params
    params.permit(:name, :optimistic, :realistic, :pessimistic, :note)
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_project_estimate
    @estimate = @project.estimates.find_by!(id: params[:id]) if @project
  end

end
