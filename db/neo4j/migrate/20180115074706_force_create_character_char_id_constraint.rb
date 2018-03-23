class ForceCreateCharacterCharIdConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Character, :char_id, force: true
  end

  def down
    drop_constraint :Character, :char_id
  end
end
