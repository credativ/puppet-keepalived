class keepalived (
    $ensure             = params_lookup('ensure'),
    $manage_config      = params_lookup('manage_config'),
    $config_source      = params_lookup('config_source'),
    $config_template    = params_lookup('config_template')
    ) {

    package { 'keepalived':
        ensure => $ensure
    }

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
