# Class for creating the RoundCube postgresql database.
class roundcube::database::postgresql (
  $install_postgresql      = $roundcube::params::install_postgresql,
  $ip_mask_allow_all_users = $roundcube::params::ip_mask_allow_all_users,
  $listen_addresses        = $roundcube::params::listen_addresses,

  $database_name           = $roundcube::database_name,
  $database_username       = $roundcube::database_username,
  $database_password       = $roundcube::database_password,
) inherits roundcube::params {

  # Installation
  if ($install_postgresql) {
	  class { '::postgresql::server':
	    ip_mask_allow_all_users => $ip_mask_allow_all_users,
	    listen_addresses        => $listen_addresses,
	  }
  }

  # Database
  postgresql::server::db { $database_name:
    user     => $database_username,
    password => $database_password,
  }

  # Role
  postgresql::server::role { $database_username:
    password_hash => postgresql_password($database_username, $database_password),
  }

  # Schema Import
  # Step 1 - Load in schema
  $postgres_home = '/var/lib/postgresql'

  file { "${postgres_home}/roundcube.postgres.sql":
    ensure => present,
    mode   => '0600',
    owner  => 'postgres',
    group  => 'postgres',
    source => 'puppet:///modules/roundcube/postgres.initial.sql',
  }

  # Step 2 - Password file
  file { "${postgres_home}/.roundcube.pgpass":
    ensure  => present,
    mode    => '0600',
    owner   => 'postgres',
    group   => 'postgres',
    content => "localhost:*:${database_name}:${database_username}:${database_password}\n",
    require => Postgresql::Server::Db[$database_name],
  }

  # Step 3 - Load in schema
  exec { 'roundcube_load_postgres_schema':
    user        => 'postgres',
    environment => [ "PGPASSFILE=${postgres_home}/.roundcube.pgpass" ],
    command     => "/usr/bin/psql -U ${database_username} -h localhost ${database_name} < ${postgres_home}/roundcube.postgres.sql",
    onlyif      => "/usr/bin/psql ${database_name} -c \"\\dt\" | grep -c \"No relations found.\"",
    require     => [
      Postgresql::Server::Db[$database_name],
      File["${postgres_home}/roundcube.postgres.sql"],
      File["${postgres_home}/.roundcube.pgpass"]
    ],
  }

}
