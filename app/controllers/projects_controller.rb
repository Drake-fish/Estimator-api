class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :update, :destroy]

  def index
    @projects = Project.all
    json_response(@projects)
  end

  def create
    @project = Project.create!(project_params)
    json_response(@project, :created)
  end

  def show
    json_response(@project)
  end

  def update
    @project.update(project_params)
    head :no_content
  end

  def destroy
    @project.destroy
    head :no_content
  end

  def calculate_estimate
    estimate = Estimate.find(params[:id])
    json_response(`thor estimator:estimate #{estimate.optimistic} #{estimate.realistic} #{estimate.pessimistic} -j`)
  end

  def calculate_weighted
    estimate = Estimate.find(params[:id])
    json_response(`thor estimator:estimate #{estimate.optimistic} #{estimate.realistic} #{estimate.pessimistic} -j -w`)
  end

  def average_all_estimates
    estimates = Project.all_estimates(params)
    json_response(calculate_average_of_all_estimates(estimates, false))
  end

  def average_all_weighted_estimates
    estimates = Project.all_estimates(params)
    json_response(calculate_average_of_all_estimates(estimates, true))
  end

  def calculate_average_of_all_estimates(estimates, weighted)
    response = { average: 0, standard_deviation: 0 }
    if weighted
      estimates.each do | estimate |
        response[:average] += average_weighted_numbers(estimate.optimistic, estimate.realistic, estimate.pessimistic)
        response[:standard_deviation] += standard_deviation(estimate.pessimistic, estimate.optimistic)
      end
    else
      estimates.each do | estimate |
        response[:average] += average_numbers(estimate.optimistic, estimate.realistic, estimate.pessimistic)
        response[:standard_deviation] += standard_deviation(estimate.pessimistic, estimate.optimistic)
      end
    end
    response
  end

  def average_weighted_numbers(low, real, high)
    ((low + real * 4 + high) / 6.0).round(2)
  end

  def average_numbers(low, real, high)
    ((low + real + high) / 3.0).round(2)
  end

  def standard_deviation(low, high)
    ((low - high) / 6.0).round(2)
  end

  private

  def project_params
    params.permit(:name, :description)
  end

  def set_project
    @project = Project.find(params[:id])
  end
end
