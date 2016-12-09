namespace :removed_matrikel_id do
  task :update => :environment do
    SynchronizeWithDtubase.new.call
  end
end
