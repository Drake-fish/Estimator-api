require 'json'

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :update, :destroy]

  def index
    projects = Project.get_all_projects_and_estimates
    optimistic = projects.sum(:optimistic).to_f
    realistic = projects.sum(:realistic).to_f
    pessimistic = projects.sum(:pessimistic).to_f
    average = calculate_time(optimistic, realistic, pessimistic)
    weighted = calculate_weighted(optimistic, realistic, pessimistic)
    standard_deviation = calculate_standard(projects.average(:pessimistic).to_f, projects.average(:optimistic).to_f)

    json_response({
      projects: projects,
      total_projects: projects.count,
      average_time: average,
      weighted_time: weighted,
      standard_deviation: standard_deviation
    })

  end


  def create
    @project = Project.new(project_params)
    if @project.save
      json_response(@project, :created)
    else
      json_response({status:422, message: @project.errors.full_messages })
    end
  end

  def show
    average = 0
    weighted = 0
    standard = 0
    estimates = 0
    children = []
    if @project.root? && @project.children?
      projects = @project.children
      projects.each do |child|
         task = {
          id: child.id,
          name: child.name,
          description: child.description,
          average_time: 0,
          weighted_time: 0,
          standard_deviation: 0,
          created_at: child.created_at,
          updated_at: child.updated_at,
          completed: child.completed,
          total_estimates: child.estimates.count
        }
        if child.estimates.count > 0
          child.estimates.each do |estimate|
            task[:average_time] += calculate_time(estimate.optimistic, estimate.realistic, estimate.pessimistic).to_f
            task[:weighted_time] += calculate_weighted(estimate.optimistic, estimate.realistic, estimate.pessimistic).to_f
            task[:standard_deviation] += calculate_standard(estimate.pessimistic, estimate.optimistic).to_f
          end
          task[:average_time] = (task[:average_time] / task[:estimates]).round(2)
          task[:weighted_time] = (task[:weighted_time] / task[:estimates]).round(2)
          task[:standard_deviation] = (task[:standard_deviation] / task[:estimates]).round(2)
        end

        children << task
      end
      json_response ({
        project: @project,
        children: children,
        estimates: [],
        average_time: children.reduce(0) { |sum, child| sum + child[:average_time]}.round(2),
        weighted_time: children.reduce(0) { |sum, child| sum + child[:weighted_time]}.round(2),
        standard_deviation: (children.reduce(0) { |sum, child| sum + child[:standard_deviation]} / children.length).round(2),
        total_estimates: estimates
      })
    else
      average = 0
      weighted = 0
      standard = 0
      estimates_count = @project.estimates.count
      if estimates_count > 0
        @project.estimates.each do |estimate|
          average += calculate_time(estimate.optimistic, estimate.realistic, estimate.pessimistic).to_f
          weighted += calculate_weighted(estimate.optimistic, estimate.realistic, estimate.pessimistic).to_f
          standard += calculate_standard(estimate.pessimistic, estimate.optimistic).to_f
        end
        average = (average / estimates_count).round(2)
        weighted = (weighted / estimates_count).round(2)
        standard = (standard / estimates_count).round(2)
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
    ((low + real + high) / 3.0).round(2)
  end

  def calculate_weighted(low, real, high)
    ((low + real * 4 + high) / 6.0).round(2)
  end

  def calculate_standard(high, low)
    ((high - low)/6.0).round(2)
  end

  def project_params
    params.permit(:name, :description, :parent_id, :completed)
  end

  def set_project
    @project = Project.find_project_by_id(params)
  end
end
