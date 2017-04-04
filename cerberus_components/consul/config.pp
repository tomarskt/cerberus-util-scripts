class cerberus::consul::config {

  class { 'consul':
    consul_run_mode => 'server',
    bootstrap_expect => '3',
  }

}