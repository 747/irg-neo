class ForceCreateSeriesNameIndex < Neo4j::Migrations::Base
  def up
    add_index :Series, :name, force: true
  end

  def down
    drop_index :Series, :name
  end
end
