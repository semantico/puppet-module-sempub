
#nfs_mount { device => "tarragon.semantico.net:/opt/semantico/account" , mnt_point => "/opt/semantico/data/account" }
define nfs_mount($device, 
                 $mnt_point, 
                 $nfs_options = "rw,hard,intr,nolock",
                 $ensure = 'present'
                 ) {

    file { "${mnt_point}":
        ensure => directory,
    }

    if $ensure == 'absent' {
        mount { "${mnt_point}":
            ensure  => absent,
            name    => $mnt_point,
        }
    } else {
        mount { "${mnt_point}":
            ensure  => "mounted",
            name    => $mnt_point,
            device  => $device,
            fstype  => "nfs",
            options => $nfs_options,
            require => File[$mnt_point],
        }
    }

}

