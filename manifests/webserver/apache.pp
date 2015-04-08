class roundcube::webserver::apache (
  # Install Apache
  $install_apache       = $roundcube::params::install_apache,
  $default_vhost_on     = $roundcube::params::default_vhost_on,
  $default_mods         = $roundcube::params::default_mods,
  $default_confd_files  = $roundcube::params::default_confd_files,
  $purge_configs        = $roundcube::params::purge_configs,
  $mpm_module           = $roundcube::params::mpm_module,
  $install_apache_mods  = $roundcube::params::install_apache_mods,

  $ssl                  = $roundcube::params::ssl,
  $redirect_to_ssl      = $roundcube::params::redirect_to_ssl,

  $port                 = $roundcube::params::port,
  $non_ssl_port         = $roundcube::params::non_ssl_port,

  $servername           = $roundcube::params::servername,
  $serveraliases        = $roundcube::params::serveraliases,

  $documentroot         = $roundcube::params::documentroot,

  $ssl_ca               = $roundcube::params::ssl_ca,
  $ssl_cert             = $roundcube::params::ssl_cert,
  $ssl_key              = $roundcube::params::ssl_key,
) inherits roundcube::params {
  # Installation
  if ($install_apache) {
    class { '::apache':
	    default_vhost       => $default_vhost_on,
	    default_mods        => $default_mods,
	    default_confd_files => $default_confd_files,
	    purge_configs       => $purge_configs,
	    mpm_module          => $mpm_module,
	  }
  }

  if ($install_apache_mods) {
	  package { 'libapache2-mod-php5':
	    ensure => installed,
	  }

	  apache::mod { 'actions': }
	  apache::mod { 'php5': }
	  if $ssl == false {
	    apache::mod { 'mime': }
	    apache::mod { 'deflate': }
	  }
  }

  # Sensible Defaults
  if ($port == undef) {
    if ($ssl) {
      $real_port = '443'
    } else {
      $real_port = '80'
    }
  } else {
    $real_port = $port
  }

  if ($non_ssl_port == undef) {
    $real_non_ssl_port = '80'
  } else {
    $real_non_ssl_port = $non_ssl_port
  }

  # VHOST Config
  if $ssl and $redirect_to_ssl {
    apache::vhost { 'roundcube_non_ssl':
      port             => $real_non_ssl_port,
      servername       => $servername,
      serveraliases    => $serveraliases,
      docroot          => $documentroot,
      redirect_status  => 'permanent',
      redirect_dest    => "https://${servername}:${real_port}/",
    }
  }

  $scriptaliases = [
    { alias          => '/program/js/tiny_mce/',
      path           => '/usr/share/tinymce/www/' },
    { alias          => '/local/bin',
      path           => '/usr/bin' }
  ]

  $directories = [
    { path           => $documentroot,
      options        => '+FollowSymLinks',
      allow_override => 'All',
      require        => 'all granted',  # DEPRECATED SINCE Apache 2.4:
                                        #order          => 'allow,deny',
                                        #allow          => 'from all'
    },
    { path           => "${documentroot}/config",
      options        => '-FollowSymLinks',
      allow_override => 'None'
    },
    { path           => "${documentroot}/temp",
      options        => '-FollowSymLinks',
      allow_override => 'None',
      require        => 'all denied',   # DEPRECATED SINCE Apache 2.4:
                                        #order          => 'allow,deny',
                                        #deny           => 'from all'
    },
    { path           => "${documentroot}/logs",
      options        => '-FollowSymLinks',
      allow_override => 'None',
      require        => 'all denied',   # DEPRECATED SINCE Apache 2.4:
                                        #order          => 'allow,deny',
                                        #deny           => 'from all'
    },
    { path           => '/usr/share/tinymce/www/',
      options        => 'Indexes MultiViews FollowSymLinks',
      allow_override => 'None',
      require        => 'all granted',  # DEPRECATED SINCE Apache 2.4:
                                        #order          => 'allow,deny',
                                        #allow          => 'from all'
    }
  ]

  apache::vhost { 'roundcube':
    port             => $real_port,
    servername       => $servername,
    serveraliases    => $serveraliases,
    docroot          => $documentroot,
    scriptaliases    => $scriptaliases,
    ssl              => $ssl,
    ssl_ca           => $ssl_ca,
    ssl_key          => $ssl_key,
    ssl_cert         => $ssl_cert,
    directories      => $directories,
  }
}
