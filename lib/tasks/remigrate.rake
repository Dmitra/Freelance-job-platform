namespace :db do
  desc 'Drops database, recreates it, and re-runs migrations.' 
  task :remigrate => ['db:drop', 'db:create', 'db:migrate']
end