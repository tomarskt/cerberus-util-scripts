node default {
  class { 'consul':
    consul_run_mode => 'server',
    bootstrap_expect => '3',
  }
}