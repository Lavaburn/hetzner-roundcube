class roundcube (
  # Installation
  $apt_mirror                = $roundcube::params::apt_mirror,
  $roundcube_backend         = $roundcube::params::roundcube_backend,
  $install_extra_plugins     = $roundcube::params::install_extra_plugins,

  # Configuration
  $dbconfig_file             = $roundcube::params::dbconfig_file,
  $confdir                   = $roundcube::params::confdir,
  $main_inc_php_erb          = $roundcube::params::main_inc_php_erb,

  # Database
  $database_host             = $roundcube::params::database_host,
  $database_port             = $roundcube::params::database_port,
  $database_name             = $roundcube::params::database_name,
  $database_username         = $roundcube::params::database_username,
  $database_password         = $roundcube::params::database_password,
  $database_ssl              = $roundcube::params::database_ssl,

  # Extra Information for Template
  # TODO
  # $force_https               = $roundcube::params::force_https,
) inherits roundcube::params {
  # Validation
  validate_re($roundcube_backend, [ 'sqlite3', 'mysql', 'pgsql' ])

  # Sensible Defaults
  if ($database_port == undef) {
	  if ($roundcube_backend == 'pgsql') {
	    $real_database_port = '5432'
	  } elsif ($roundcube_backend == 'mysql') {
	    $real_database_port = '3306'
	  } else {
	    $real_database_port = ''
	  }
  } else {
    $real_database_port = $database_port
  }

  # Installation
  if ($apt_mirror) {
	  apt::source { 'wheezy-backports':
	    location  => $apt_mirror,
	    repos     => 'main',
	  }

	  apt::pin { 'roundcube':
	    packages => 'roundcube*',
	    priority => 1001,
	    release  => 'wheezy-backports',
	  }
  }

  package { "roundcube-${roundcube_backend}":
    ensure  => installed,
  }

  package { ['roundcube', 'roundcube-core', 'roundcube-plugins']:
    ensure  => installed,
    require => Package["roundcube-${roundcube_backend}"],
  }

  if ($install_extra_plugins) {
    package { 'roundcube-plugins-extra':
	    ensure  => installed,
	    require => Package["roundcube-${roundcube_backend}"],
	  }
  }


  # Configuration

  # Defaults
  Ini_setting {
    path    => $dbconfig_file,
    ensure  => present,
    section => '',
    notify  => Exec['reconfigure_roundcube'],
    require => Package['roundcube-core'],
  }

  ini_setting {'dbtype':
    setting => 'dbc_dbtype',
    value   => "'${roundcube_backend}'",
  }

  ini_setting {'dbuser':
    setting => 'dbc_dbuser',
    value   => "'${database_username}'",
  }

  ini_setting {'dbpass':
    setting => 'dbc_dbpass',
    value   => "'${database_password}';",
  }

  ini_setting {'dbname':
    setting => 'dbc_dbname',
    value   => "'${database_name}';",
  }

  ini_setting {'dbserver':
    setting => 'dbc_dbserver',
    value   => "'${database_host}';",
  }

  ini_setting {'dbport':
    setting => 'dbc_dbport',
    value   => "'${real_database_port}';",
  }

  ini_setting {'dbssl':
    setting => 'dbc_ssl',
    value   => "'${database_ssl}';",
  }

  # Apply Settings
  exec { 'reconfigure_roundcube':
    command     => '/usr/sbin/dpkg-reconfigure roundcube-core',
    refreshonly => true,
  }

  # Setup webconfig (template)
  file { "${confdir}/main.inc.php":
    owner   => root,
    group   => www-data,
    mode    => '0640',
    content => template($main_inc_php_erb),
  }
}
