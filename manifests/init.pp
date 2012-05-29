class keepalived (
    $ensure             = params_lookup('ensure'),
    $manage_config      = params_lookup('manage_config'),
    $ensure_running     = params_lookup('ensure_running'),
    $ensure_enabled     = params_lookup('ensure_enabled'),
    $config_source      = params_lookup('config_source'),
    $config_template    = params_lookup('config_template')
    ) inherits keepalived::params {

    package { 'keepalived':
        ensure => $ensure
    }

    service { 'keepalived':
        ensure      => $ensure_running,
        enabled     => $ensure_enabled,
        hasrestart  => true,
        hasstatus   => true,


    file { '/etc/keepalived.conf':
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
    }

    if $config_source {
        File <| title == '/etc/keepalived.conf' |> {
            source  => $config_source
        }
    } else {
        File <| title == '/etc/keepalived.conf' |> {
            content => template($config_template)
        }
    }
}
