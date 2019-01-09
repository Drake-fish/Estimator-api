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
    @project.estimates.create!(estimate_params)
    json_response(@project, :created)
  end

  def update
    @estimate.update(estimate_params)
    head :no_content
  end

  def destroy
    @project.destroy
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
