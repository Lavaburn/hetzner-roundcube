class roundcube::webservice::apache (
  $default_vhost_on     = $roundcube::params::default_vhost_on,
  $servername           = $roundcube::params::servername,
  $serveraliases        = $roundcube::params::serveraliases,
  $documentroot         = $roundcube::params::documentroot,
  $addhandlers          = $roundcube::params::addhandlers,
  $purge_configs        = $roundcube::params::purge_configs,
  $default_mods         = $roundcube::params::purge_configs,
  $default_confd_files  = $roundcube::params::purge_configs,
  $mpm_module           = $roundcube::params::mpm_module,
  $redirect_to_ssl      = $roundcube::params::redirect_to_ssl,
  $ssl                  = $roundcube::params::ssl,
  $ssl_ca               = $roundcube::params::ssl_ca,
  $ssl_cert             = $roundcube::params::ssl_cert,
  $ssl_key              = $roundcube::params::ssl_key,
  $scriptaliases        = [ { alias          => '/program/js/tiny_mce/',
                              path           => '/usr/share/tinymce/www/' },
                            { alias          => '/local/bin',
                              path           => '/usr/bin' } ],
  $apache_port          = $roundcube::params::apache_port,
  $directories          = [ { path           => $documentroot,
                              options        => '+FollowSymLinks',
                              allow_override => 'All',
                              order          => 'allow,deny',
                              allow          => 'from all' },
                            { path           => "${documentroot}/config",
                              options        => '-FollowSymLinks',
                              allow_override => 'None' },
                            { path           => "${documentroot}/temp",
                              options        => '-FollowSymLinks',
                              allow_override => 'None',
                              order          => 'allow,deny',
                              allow          => 'from none' },
                            { path           => "${documentroot}/logs",
                              options        => '-FollowSymLinks',
                              allow_override => 'None',
                              order          => 'allow,deny',
                              allow          => 'from none' },
                            { path           => '/usr/share/tinymce/www/',
                              options        => 'Indexes MultiViews FollowSymLinks',
                              allow_override => 'None',
                              order          => 'allow,deny',
                              allow          => 'from all' },
                          ],
  ) inherits roundcube::params {

  class { '::apache':
    default_vhost       => $default_vhost_on,
    default_mods        => $default_mods,
    default_confd_files => $default_confd_files,
    purge_configs       => $purge_configs,
    mpm_module          => $mpm_module,
  }

  package { 'libapache2-mod-php5':
    ensure => installed,
  }

  apache::mod { 'actions': }
  apache::mod { 'php5': }
  if $ssl == false {
    apache::mod { 'mime': }
    apache::mod { 'deflate': }
  }

  if $redirect_to_ssl == true {
    apache::vhost { 'roundcube_non_ssl':
      port             => 80,
      servername       => $servername,
      serveraliases    => $serveraliases,
      docroot          => $documentroot,
      redirect_status  => 'permanent',
      redirect_dest    => "https://${servername}/",
    }
    apache::vhost { 'roundcube':
      port             => $apache_port,
      servername       => $servername,
      serveraliases    => $serveraliases,
      docroot          => $documentroot,
      scriptaliases    => $scriptaliases,
      ssl              => $ssl,
      ssl_ca           => $ssl_ca,
      ssl_key          => $ssl_key,
      ssl_cert         => $ssl_cert,
      directories      => [ $directories,
        addhandlers    => $addhandlers,
      ],
    }
  } else {
    apache::vhost { 'roundcube':
      port             => $apache_port,
      servername       => $servername,
      serveraliases    => $serveraliases,
      docroot          => $documentroot,
      scriptaliases    => $scriptaliases,
      ssl              => $ssl,
      ssl_ca           => $ssl_ca,
      ssl_key          => $ssl_key,
      ssl_cert         => $ssl_cert,
      directories      => [ $directories,
        addhandlers    => $addhandlers,
      ],
    }
  }

}
