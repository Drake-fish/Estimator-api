class Project < ApplicationRecord
  has_many :estimates, dependent: :destroy
  has_ancestry
  validates_presence_of :name, :description

  scope :get_all_projects_and_estimates, -> { includes(:estimates ).where(ancestry: nil).order(created_at: :desc) }
  scope :find_project_by_id, -> (params) { includes(:estimates).find(params[:id]) }

  def get_parent_calculations
  parent_sql = <<-SQL
    SELECT
        ROUND((t.opt + t.real + t.pess)/3, 2) AS average,
        ROUND((t.opt + t.real * 4 + t.pess)/6, 2) AS weighted,
        ROUND((t.pess - t.opt)/6, 2) AS standard
   FROM (
    SELECT
          p.id as parent_id,
          e.optimistic as optimistic,
          q.id as child_id,
          AVG(e.optimistic) as opt,
          AVG(e.realistic) as real,
          AVG(e.pessimistic) as pess,
          e.id as estimate_id
       FROM projects p
       JOIN projects q
       ON p.id = q.ancestry::int
       JOIN estimates e
       ON q.id = e.project_id
       GROUP BY q.id, p.id, e.optimistic, e.id
       ) as t;
    SQL
    ActiveRecord::Base.connection.exec_query(parent_sql)
  end

  def get_children
      child_sql = <<-SQL
        SELECT
          t.child_id as id,
          ROUND((t.opt + t.real + t.pess)/3, 2) as average,
          ROUND((t.opt + t.real * 4 + t.pess)/6, 2) as weighted,
          ROUND((t.pess - t.opt)/6,2) as standard,
          t.name as name,
          t.description as description,
          t.created_at as created_at,
          t.updated_at as updated_at,
          t.completed as completed,
          total_estimates
      FROM (
        SELECT
               q.id as child_id,
               q.name as name,
               q.description as description,
               q.ancestry as ancestry,
               q.created_at as created_at,
               q.updated_at as updated_at,
               q.completed as completed,
               AVG(e.optimistic) as opt,
               AVG(e.realistic) as real,
               AVG(e.pessimistic) as pess,
               count(e.optimistic) as total_estimates
        FROM projects p
        LEFT OUTER JOIN projects q
        ON p.id::int = q.ancestry::int
        JOIN estimates e
        ON q.id = e.project_id
        GROUP BY q.id
      ) AS t;
    SQL
    ActiveRecord::Base.connection.exec_query(child_sql)
  end

  def get_task_calculations(id)
        task_sql = <<-SQL
        SELECT SUM(average) as average, SUM(weighted) as weighted, SUM(standard) as standard
        FROM (
            SELECT
                p.id,
                ROUND((e.optimistic + e.realistic + e.pessimistic)/3.0, 2) as average,
                ROUND((e.optimistic + e.realistic * 4 + e.pessimistic)/6.0, 2) as weighted,
                ROUND((e.pessimistic - e.optimistic)/6.0, 2) as standard
            FROM projects p
            LEFT JOIN estimates e
            ON p.id = e.project_id
            WHERE p.id = #{id}
        ) as t
      SQL
      ActiveRecord::Base.connection.exec_query(task_sql)
  end
end
