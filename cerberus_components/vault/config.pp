class cerberus::vault::config {

  class { 'consul':
    consul_run_mode => 'agent',
  }

  include 'vault'

}