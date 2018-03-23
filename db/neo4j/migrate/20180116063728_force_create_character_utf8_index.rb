class ForceCreateCharacterUtf8Index < Neo4j::Migrations::Base
  def up
    add_index :Character, :utf8, force: true
  end

  def down
    drop_index :Character, :utf8
  end
end
