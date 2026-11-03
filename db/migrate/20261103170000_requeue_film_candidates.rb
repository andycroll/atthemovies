class RequeueFilmCandidates < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE films SET enrichment_state = 'pending' WHERE enrichment_state = 'candidates'"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
