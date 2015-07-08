# gemspec data
Gem::Specification.new do |spec|
  spec.name               = 'mv_threads'
  spec.version            = '0.0.3.1'
  spec.authors            = ['YuryDG','jmorrispratt', 'MaxAntonio']
  spec.email              = %q{x@example.com}
  spec.summary            = %q{MvThreads gem summary}
  spec.description        = %q{Something}
  spec.homepage           = %q{http://cienfuegos.org/mv_threads}
  spec.license            = 'MIT'
  spec.date               = %q{2015-01-22}

  # spec.files = Dir['lib/   *.rb'] + Dir['bin/*']
  # spec.files += Dir['[A-Z]*'] + Dir['test/**/*']

  spec.files              = [
  	'Rakefile',
  	'lib/mv_threads.rb',
    'lib/mv_threads.pid',
  	'lib/mv_threads/data_loggers.rb',
  	'lib/mv_threads/data_storage_type.rb',
  	'lib/mv_threads/network_engine.rb',
  	'lib/mv_threads/parsing_engine.rb',
  	'lib/mv_threads/parsing_error_type.rb',
  	'lib/mv_threads/processing_engine.rb',
  	'lib/mv_threads/hdd/___readme___.txt',
  	'lib/mv_threads/ram/___readme___.txt',
  	'lib/mv_threads/db/db_create.rb',
  	'lib/mv_threads/db/db_migrate.rb',
  	'lib/mv_threads/db/database.yml',
  	'lib/mv_threads/db/migrations/create_failed_sequence_table.rb',
    'lib/mv_threads/db/migrations/create_json_sequence_table.rb',
    'lib/mv_threads/db/migrations/create_parsed_sequence_table.rb',
  	'lib/mv_threads/db/migrations/create_received_sequence_table.rb',
  	'lib/mv_threads/db/models/failed_sequence.rb',
    'lib/mv_threads/db/models/json_sequence.rb',
  	'lib/mv_threads/db/models/parsed_sequence.rb',
  	'lib/mv_threads/db/models/received_sequence.rb',
    'lib/scripts/bmv_client.rb',
    'lib/scripts/db_create.rb',
    'lib/scripts/db_migrate.rb',
    'lib/scripts/ip_tests.rb',
    'lib/scripts/pid_tests.rb',
    'lib/scripts/sequences.txt',
  	'bin/mv_threads',
    'lib/tasks/start.rake',
  ]

  spec.default_executable = 'mv_threads'
  spec.test_files         = ['test/test_mv.rb']
  spec.require_paths      = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
end
