namespace :mv_threads do
  require 'raven'
  require 'mv_threads'
  Raven.configure do |config|
    config.dsn = 'https://b0667c7b231c49fa8f640240568090c5:314dc744a256430daa5bd159b0d9523c@app.getsentry.com/41274'
  end

  task :start do
    #utilizando raven para detectar errores
    Raven.capture do
      MvThreads.start(1)
    end
  end

  task :status do
    MvThreads.status
  end

  task :saludo do
    puts "estas en el mundo de MV"
  end

end
