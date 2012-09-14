#
# Note, this define is only really required because the puppet service type
# does not handle start/stop values for debian update-rc.d.
#
# If it does, this should be ditched, and all instanciations of it migrated to
# use service{}
# 
# MP, 2008-09

define sempub::sysv_init_links ( 
                    $start = 99,
                    $stop  = 01,
                    $runlevel_list = [ 3, 4, 5 ],
                    $runlevel_list_concat = 345,
                    $path = "/usr/sbin:/usr/bin:/bin:/sbin",
                    $ensure = "present"
                ) {

        $id = "sempub_sysv_init_links_$title"

        Exec { path => $path }

        case $ensure { 
            "present": {
                case $operatingsystem {
                    debian,ubuntu: { 
                        exec { "${id}_updatercd":
                            command => "update-rc.d $title defaults $start $stop",
                            unless  => [ "test -h /etc/rc3.d/S${start}${title}", "test -h /etc/rc3.d/K${stop}${title}" ],
                        }
                    }
                    redhat,centos: {
                        exec { "${id}_chkconfig":
                            command => "chkconfig --level $runlevel_list_concat $title on",
                            unless  => "chkconfig --list $title | /bin/grep on",
                        }
                    }
                    default: { fail("$hostname: sempub::sysv_init_links - not supported on $operatingsystem") }
                }
            }
            "absent": { 
                case $operatingsystem {
                    debian,ubuntu: { 
                        exec { "${id}_updatercd":
                            command => "update-rc.d -f $title remove",
                            onlyif  => [ "test -h /etc/rc3.d/S*${title}" ],
                        }
                    }
                    default: {
                        fail("$hostname: sempub::sysv_init_links - ensure => $ensure not supported on $operatingsystem") 
                    }
                }
            }
            default: { fail("$hostname: sempub::sysv_init_links - ensure => $ensure invalid") } 
        }

}
