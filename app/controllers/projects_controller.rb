require 'json'

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :update, :destroy]

  def index
    projects = Project.get_all_projects_and_estimates
    optimistic = projects.average(:optimistic).to_f
    realistic = projects.average(:realistic).to_f
    pessimistic = projects.average(:pessimistic).to_f
    average = calculate_time(optimistic, realistic, pessimistic)
    weighted = calculate_weighted(optimistic, realistic, pessimistic)
    standard_deviation = calculate_standard(pessimistic, optimistic)

    json_response({
      projects: projects,
      total_projects: projects.count,
      average_time: average,
      weighted_time: weighted,
      standard_deviation: standard_deviation
    })

  end


  def create
    #create! will crash catestrophically. Change to normal create when in production. if true this else there was an error.
    @project = Project.create(project_params)
    json_response(@project, :created)
  end

  def show
    optimistic = @project.estimates.average(:optimistic)
    realistic = @project.estimates.average(:realistic)
    pessimistic = @project.estimates.average(:pessimistic)

    estimates_count = @project.estimates.count

    if estimates_count > 0

      average = calculate_time(optimistic, realistic, pessimistic).to_f
      weighted = calculate_weighted(optimistic, realistic, pessimistic).to_f
      standard_deviation = calculate_standard(pessimistic, optimistic).to_f

      json_response({
                      project: @project,
                      total_estimates: estimates_count,
                      average_time: average,
                      weighted_time: weighted,
                      standard_deviation: standard_deviation,
                      estimates: @project.estimates
                    })
    else
      json_response ({
        project: @project,
        total_estimates: estimates_count,
        average_time: 0,
        weighted_time: 0,
        standard_deviation: 0,
        estimates: []
      })
    end
  end

  def update
    @project.update(project_params)
    head :no_content
  end

  def destroy
    @project.destroy
    head :no_content
  end

  private

  def calculate_time(low, real, high)
    ((low + real + high) / 3).round(2)
  end

  def calculate_weighted(low, real, high)
    ((low + real * 4 + high) / 6).round(2)
  end

  def calculate_standard(high, low)
    ((high - low)/6).round(2)
  end

  def project_params
    params.permit(:name, :description)
  end

  def set_project
    @project = Project.includes(:estimates).find(params[:id])
  end
end
