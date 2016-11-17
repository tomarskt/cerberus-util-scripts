node default {
  # Make sure we have the /opt/cerberus directory for placing the server artifacts/scripts in a known location.
  file { '/opt/cerberus/' :
    ensure   => directory,
    owner    => 'ubuntu',
    group    => 'ubuntu',
    mode     => '0755'
  }

  # Create the directory where the log files will go.
  file { '/var/log/cms' :
    ensure   => directory,
    owner    => 'ubuntu',
    group    => 'ubuntu',
    mode     => '0755'
  }

  # Copy the init script to its final location.
  file { '/etc/init.d/cms':
    ensure   => present,
    owner    => 'root',
    group    => 'root',
    mode     => '0755',
    source   => "/tmp/init-script.sh",
  }

  # Copy the server startup script to its final location (the init script calls this).
  file { '/opt/cerberus/start-cms.sh':
    ensure   => present,
    owner    => 'ubuntu',
    group    => 'ubuntu',
    mode     => '0755',
    source   => "/tmp/start-jar-script.sh",
    require  => File['/opt/cerberus/'],
  }

  # Copy the default JVM behavior args script to its final location (the server startup script sources this to get default JVM behavior args like heap memory size, garbage collection tweaks, etc).
  file { '/etc/default/jvm-behavior-args':
    ensure   => present,
    owner    => 'ubuntu',
    group    => 'ubuntu',
    mode     => '0644',
    source   => "/tmp/jvm-behavior-args.sh",
  }

  # Copy the server jar to its final location.
  file { '/opt/cerberus/cms.jar':
    ensure   => present,
    owner    => 'ubuntu',
    group    => 'ubuntu',
    mode     => '0755',
    source   => "/tmp/app-server.jar",
    require  => File['/opt/cerberus/'],
  }

  # Add log rotation for the server's stdout and stderr piped files. These should not grow beyond a few bytes in practice as all the real logs should go to the application's official
  #   log files, but just in case we'll give them a small max size limit to make sure they can't take the box down by filling up the disk.
  file { '/etc/logrotate.d/cms':
    owner   => 'ubuntu',
    content => '/var/log/cms/client.err /var/log/cms/client.out {
    rotate 7
    size 50M
    missingok
    copytruncate
    compress
}
',
  }

  # Add the application to the system's list of startup services. This causes the app's init script to be executed on machine startup.
  service { "cms":
    enable  => true,
    require => File['/etc/init.d/cms'],
  }
}