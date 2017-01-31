# This file is used by Rack-based servers to start the application.

if ENV['RAILS_ENV'] == 'production' || ENV['RAILS_ENV'] == 'staging'
  require 'unicorn/worker_killer'
  use Unicorn::WorkerKiller::MaxRequests, 500, 650
  oom_min = (240) * (1024**2)
  oom_max = (300) * (1024**2)
  use Unicorn::WorkerKiller::Oom, oom_min, oom_max
end


require ::File.expand_path('../config/environment',  __FILE__)
use Rack::Deflater
run Kassi::Application
