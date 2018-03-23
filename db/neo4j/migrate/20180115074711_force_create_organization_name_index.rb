class ForceCreateOrganizationNameIndex < Neo4j::Migrations::Base
  def up
    add_index :Organization, :name, force: true
  end

  def down
    drop_index :Organization, :name
  end
end
