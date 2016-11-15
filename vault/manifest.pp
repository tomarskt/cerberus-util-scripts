node default {
  class { 'consul':
    consul_run_mode => 'agent',
  }

  include 'vault'
}