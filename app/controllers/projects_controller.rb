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
      estimates_count = 0
      average_time = 0
      weighted_time = 0
      standard_deviation = 0

      @project.children.each do |child|
        estimates_count += child.estimates.count
        opt = child.estimates.average(:optimistic)
        real = child.estimates.average(:realistic)
        pess = child.estimates.average(:pessimistic)
        if child.estimates.count > 0
          average_time += calculate_time(opt, real, pess).to_f
          weighted_time += calculate_weighted(opt, real, pess).to_f
          standard_deviation += calculate_standard(pess, opt).to_f
        end
      end

      json_response ({
        project: @project,
        children: @project.children,
        estimates: [],
        average_time: average_time,
        weighted_time: weighted_time,
        standard_deviation: standard_deviation,
        estimate_count: estimates_count
      })

    else
      estimates_count = @project.estimates.count
      if estimates_count > 0
        opt = @project.estimates.average(:optimistic)
        real = @project.estimates.average(:realistic)
        pess = @project.estimates.average(:pessimistic)
      else
        opt = 0
        real = 0
        pess = 0
      end
      json_response ({
        project: @project,
        children: [],
        estimates: @project.estimates,
        average_time: calculate_time(opt, real, pess).to_f,
        weighted_time: calculate_weighted(opt, real, pess).to_f,
        standard_deviation: calculate_standard(pess, opt).to_f,
        estimate_count: estimates_count
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
    params.permit(:name, :description, :parent_id)
  end

  def set_project
    @project = Project.includes(:estimates).find(params[:id])
  end
end
