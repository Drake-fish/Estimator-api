class Project < ApplicationRecord
  has_many :estimates, dependent: :destroy
  has_ancestry
  validates_presence_of :name, :description

  scope :get_all_projects_and_estimates, -> { includes(:estimates, :projects).where(ancestry: nil).order(created_at: :desc) }
  scope :find_project_by_id, -> (params) { includes(:estimates).find(params[:id]) }

  def get_parent_calculations
  parent_sql = <<-SQL
  Select
    sum(round((t.opt + t.real + t.pess) / 3, 2)) as average,
    sum(round((t.opt + (4 * t.real) + t.pess) / 6, 2)) as weighted,
    sum(round((t.pess - t.opt)/6, 2)) as standard
 from (
  SELECT
        p.id as parent_id,
        q.id as child_id,
        avg(e.optimistic) as opt,
        avg(e.realistic) as real,
        avg(e.pessimistic) as pess
     from projects p
     left outer join projects q
     on p.id = q.ancestry
     join estimates e
     on q.id = e.project_id
     group by q.id
     ) as t;
  SQL
    ActiveRecord::Base.connection.exec_query(parent_sql)[0]
  end

  def get_children
      child_sql = <<-SQL
      Select
        t.child_id as id,
        round((t.opt + t.real + t.pess)/3, 2) as average,
        round((t.opt + t.real * 4 + t.pess)/6, 2) as weighted,
        round((t.pess - t.opt)/6,2) as standard,
        t.name as name,
        t.description as description,
        t.created_at as created_at,
        t.updated_at as updated_at,
        t.completed as completed,
        total_estimates
    from (
    SELECT
           q.id as child_id,
           q.name as name,
           q.description as description,
           q.ancestry as ancestry,
           q.created_at as created_at,
           q.updated_at as updated_at,
           q.completed as completed,
           avg(e.optimistic) as opt,
           avg(e.realistic) as real,
           avg(e.pessimistic) as pess,
           count(e.optimistic) as total_estimates
    from projects p
    left outer join projects q
    on p.id = q.ancestry
    join estimates e
    on q.id = e.project_id
    group by q.id
    ) as t;
    SQL
    ActiveRecord::Base.connection.exec_query(child_sql)
  end

  def get_task_calculations(id)
        task_sql = <<-SQL
        select
            round((e.optimistic + e.realistic + e.pessimistic)/3.0, 2) as average,
            round((e.optimistic + e.realistic * 4 + e.pessimistic)/6.0, 2) as weighted,
            round((e.pessimistic - e.optimistic)/6.0, 2) as standard
            from projects p
            left join estimates e
            on p.id = e.project_id
            where p.id = id
      SQL
      ActiveRecord::Base.connection.exec_query(task_sql)
  end
end
