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
    @project = Project.create(project_params)
    json_response(@project, :created)
  end

  def show
    if @project.root? && @project.children?
      parent_calculations = @project.get_parent_calculations
      children = @project.get_children
      json_response ({
        project: @project,
        children: children,
        estimates: [],
        average: parent_calculations.reduce(0) { |sum, project| sum + project["average"].to_f  },
        weighted: parent_calculations.reduce(0) { |sum, project| sum + project["weighted"].to_f  },
        standard: parent_calculations.reduce(0) { |sum, project| sum + project["standard"].to_f  },
        total_estimates: children.reduce(0) { |sum, project| sum + project["total_estimates"].to_i }
      })
    else
      estimates_count = @project.estimates.count
      if estimates_count > 0
        task_averages = @project.get_task_calculations(@project.id)[0]
        average = task_averages["average"].to_f
        weighted = task_averages["weighted"].to_f
        standard = task_averages["standard"].to_f
        # average, weighted, standard = task_averages.values.map(&:to_f)
      else
        average = 0
        weighted = 0
        standard = 0
      end
      json_response ({
        project: @project,
        children: [],
        estimates: @project.estimates,
        average_time: average,
        weighted_time: weighted,
        standard_deviation: standard,
        total_estimates: estimates_count
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
    params.permit(:name, :description, :parent_id, :completed)
  end

  def set_project
    @project = Project.find_project_by_id(params)
  end
end
