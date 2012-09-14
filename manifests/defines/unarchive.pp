#!/usr/bin/env puppet
#
#
# * Copyright (c) 2008, Mike Pountney (Mike.Pountney@semantico.com)
# * All rights reserved.
# *
# * Redistribution and use in source and binary forms, with or without
# * modification, are permitted provided that the following conditions are met:
# *     * Redistributions of source code must retain the above copyright
# *       notice, this list of conditions and the following disclaimer.
# *     * Redistributions in binary form must reproduce the above copyright
# *       notice, this list of conditions and the following disclaimer in the
# *       documentation and/or other materials provided with the distribution.
# *     * Neither the name of the <organization> nor the
# *       names of its contributors may be used to endorse or promote products
# *       derived from this software without specific prior written permission.
# *
# * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY
# * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
# * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 

#
# This defined type handles the unarchiving of a given file, for instance
# tgz, tbz, tar, files.
#
# It should be extendable to handle other archive formats: zip and rar are planned.
# BSD tar has not yet been tested, but should /mostly/ work
#
# Dependencies: GNU tar
#               md5sum
#
#

define sempub::unarchive ( 
            $target_dir,    # the target dir of the archive - the directory
                            # that we ultimately remove, on marking absent
            $extract_dir = "",    # the dir to extract to. defaults to the target dir
            $link_to_target = "", # optional link to the target directory, eg to do: sitecode -> sams_1_1_2
                                  # - must be an absolute path.
            $source = "",   # for FILE resource mgmt - can get archive from 
                            # anywhere File can.
            $content = "",  # for FILE resource mgmt - so we can include small 
                            # archives in manifest
            $umask       = "",   # umask to extract file using
            $user        = "root",      # user to extract archive as
            $group       = "root",      # group to extract archive as
            $path        = "/bin:/usr/bin",  # PATH env for finding 
                                             # unarchive cmd (eg tar)
            $permissions = 'preserve',  # whether to 'preserve' or 'omit' 
                                        # archive permissions.
            $compression = 'gzip',      # 'bzip2', 'none'
            $remove_existing_target = false, # whether to purge the existing target
                                             # before overwriting, and whether it should be removed
                                             # when marked 'absent'
            $provider    = 'gnutar',    # the archive tool to use
            $ensure      = 'present' ) {

    $prefix = "sempub_unarchive"   # internal prefix to add to temp files, etc.
    $state_dir = '/var/lib/puppet/state/modules/sempub'  # where to put our working files: downloaded archives, checksums, etc.

    include sempub::virtual_resources

    case $provider {
        gnutar:  { }
        zip:  { }        
        default: { fail("Unsupported provider: $compression") }
    }

    case $compression {
        gzip:  { $tar_compress_opt = '-z' }
        bzip2: { $tar_compress_opt = '-j' }
        none:  { $tar_compress_opt = '' }
        zip:  { $zip_compress_opt = '' }
        default: { fail("Invalid compression option: $compression") }
    }

    case $permissions {
        preserve: { 
            $gnutar_perms_opt = '-p' 
        }
        omit: { 
            $gnutar_perms_opt = '--no-same-owner --no-same-permissions'
        }
    }

    case $extract_dir {
        "": { $our_extract_dir = $target_dir }
        default: { $our_extract_dir = $extract_dir }
    }

    case $user {
        "": { fail("Blank user specified: cannot continue") }
        default: { }
    }

    # General sanity checking of $target_dir - must be absolute.
    case $target_dir {
        "": { fail("Cannot have an empty target_dir") }
        default: { 
            # This generate call should be replaced with an is_absolute_filename() custom function:
            if generate('/usr/bin/env', 'ruby', '-e', 'puts :true if eval ARGV[0]', "'$target_dir' =~ /\\/\\.\\.\\// || '$target_dir' =~ /\\/\\.\\.\$/ || '$target_dir' =~ /^[^\\/]/") {
                fail("target_dir ($target_dir) must be absolute")
            }
        }
    }

    if $remove_existing_target {
        # Don't want to remove '/'!
        case $target_dir {
            "/": { fail("Cannot remove a target dir of /. Failing for safety reasons.") }
            default: { }
        }
    }

    # 
    # A unique identifier for all our type calls in this define(),
    # specifically for calls where there is no natural uniqueness
    # in naming guaranteed (eg exec)
    $id = "${prefix}.${title}"

    # The staging and checksum files we use to know how and when to extract the archive
    $archive = "${state_dir}/${id}.copied_file"     # downloaded archive file
    $curr = "${state_dir}/${id}.current_checksum"   # 
    $pend = "${state_dir}/${id}.pending_checksum"
    
    # How to check that we have not already extracted the archive file successfully.
    $compare_checksums_cmd = "/usr/bin/env ruby -e 'exit ! File.exists?(\"$curr\") || File.read(\"$pend\") != File.read(\"$curr\")'"
    

    case $ensure {
        present: {
            
            # Ensure that our staging directory exists
            realize File["$state_dir"]

            # copy archive file to a local file
            #   - unless source is already local - how to tell?
            #     - just ignore this for now: optimise later.
            # File type provides idempotency, yey.
            if $source {
                file { "$archive":
                    source => "$source",
                    mode => 600,
                    owner => $user,
                    group => $group,
                    require => File["${state_dir}"],
                }
            } else {
                if $content {
                    file { "$archive":
                        content => "$content",
                        mode => 600,
                        owner => $user,
                        group => $group,
                        require => File["${state_dir}"],
                    }
                } else {
                    fail("Need to specify either 'content' or 'source'")
                }
            }

            # Checksum the local file
            #  - could do a 'confirm checksum' check here,
            #    using a supplied checksum
            exec { "${id}.pending_checksum":
                cwd => "$state_dir",
                path => "$path",
                command => "md5sum ${archive} > ${pend}",
                onlyif => ["[ -f ${archive} ]",
                           "[ ! -f ${pend} ] || [ ${archive} -nt ${pend} ]"
                           ],
                require => File["$archive"],
            }

            # Ensure we have a directory to extract into
            #  - cannot use File, as it does not permit
            #    two instances of unarchive() to use the 
            #    same target directory.
            exec { "${id}.make_target_dir":
                path => "$path",
                command => "mkdir -p $target_dir && chown $user $target_dir && chgrp $group $target_dir",
                onlyif => [ "[ ! -d $target_dir ]",
                            "[ ! -f $target_dir ]"
                          ],
                require => Exec["${id}.pending_checksum"],
            }

            # If flagged to remove the existing target dir, do so.
            case $remove_existing_target {
                false: { }
                true: {
                            # ditch the existing contents
                            exec { "${id}.remove_existing":
                                path => "$path",
                                command => "rm -rf ${target_dir}",
                                onlyif => "$compare_checksums_cmd",
                                require => Exec["${id}.make_target_dir"],
                            }

                            # and remake the top-level...
                            exec { "${id}.remake_target_dir":
                                path => "$path",
                                command => "mkdir -p $target_dir && chown $user $target_dir && chgrp $group $target_dir",
                                onlyif => [ "[ ! -d $target_dir ]",
                                            "[ ! -f $target_dir ]"
                                          ],
                                require => Exec["${id}.remove_existing"],
                            }

                }
            }

            # If checksum does not match, then we can 
            # run our unarchive command.
            exec { "${id}.unarchive_exec":
                cwd => "$our_extract_dir",
                path => "$path",
                user => "$user",
                group => "$group",
                
                command => $provider ? {
                    "gnutar" => $umask ? { 
                        ""      => "tar $tar_compress_opt $gnutar_perms_opt -x -f $archive",
                        default => "bash -c 'umask $umask && tar $tar_compress_opt $gnutar_perms_opt -x -f $archive'",
                    },
                    "zip"    => "unzip -u $zip_compress_opt $archive" 
                },
                onlyif => "$compare_checksums_cmd",
                require => $remove_existing_target ? {
                    true =>   Exec["${id}.remake_target_dir"],
                    default =>  Exec["${id}.make_target_dir"]
                }
            }

            # If all went well with the unarchive, update the
            # checksum of the 'current unarchive'.
            file { "$curr":
                source => "${state_dir}/${id}.pending_checksum",
                mode => 600,
                owner => $user,
                group => $group,
                subscribe => Exec["${id}.unarchive_exec"],
            }

            # If all went well with the unarchive, update the
            # checksum of the 'current unarchive'.
            if $link_to_target {
                file { "$link_to_target":
                    ensure => "$target_dir",   # dest of link
                    backup => false, # not needed - we're just moving links.
                    subscribe => Exec["${id}.unarchive_exec"],
                }
            }

        }
        absent: {
            # remove archive file
            file { "$archive": ensure => absent }

            # remove checksum/flag files
            file { "$curr": ensure => absent }
            file { "$pend": ensure => absent }

            # If flagged to remove the existing target dir, do so.
            case $remove_existing_target {
                false: { }
                true: {
                            exec { "${id}.remove_existing":
                                path => "$path",
                                command => "rm -rf ${target_dir}/*",
                            }
                }

            }

        }

    }

}

