require 'json'

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :update, :destroy]

  def index
    @projects = Project.includes(:estimates).all.order(created_at: :desc)
    calculated_time = average_time_for_all_projects(@projects)
    json_response({projects: @projects,
                   total_projects: @projects.length,
                   average_time: calculated_time[:average],
                   weighted_time: calculated_time[:weighted],
                   standard_deviation: calculated_time[:standard_deviation] })
  end


  def average_time_for_all_projects (projects)
    response = {average: 0, weighted: 0, standard_deviation: 0}
    projects.each do | project |
      project_totals = average_time_for_project(project)
      response[:average] += project_totals[:average]
      response[:weighted] += project_totals[:weighted]
      response[:standard_deviation] += project_totals[:standard_deviation]
    end
    response
  end

  def average_time_for_project(project)
    response = { average: 0, weighted: 0, standard_deviation: 0 }
    project.estimates.each do | estimate |
      average_json = JSON.parse(`thor estimator:estimate #{estimate.optimistic} #{estimate.realistic} #{estimate.pessimistic} -j`)
      weighted_json = JSON.parse(`thor estimator:estimate #{estimate.optimistic} #{estimate.realistic} #{estimate.pessimistic} -j -w`)
      response[:average] += average_json["average"].to_f.round(2)
      response[:weighted] += weighted_json["average"].to_f.round(2)
      response[:standard_deviation] += average_json["standardDeviation"].to_f.round(2)
    end
    response
  end

  def create
    @project = Project.create!(project_params)
    json_response(@project, :created)
  end

  def show
    calculated_time = average_time_for_project(@project)
    json_response({
                    project: @project,
                    total_estimates: @project.estimates.length,
                    average_time: calculated_time[:average],
                    weighted_time: calculated_time[:weighted],
                    standard_deviation: calculated_time[:standard_deviation]
                  })
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

  def project_params
    params.permit(:name, :description)
  end

  def set_project
    @project = Project.find(params[:id])
  end
end
