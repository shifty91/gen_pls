#!/usr/bin/env perl
#
# Copyright (C) 2015 Kurt Kanzenbach <kurt@kmk-computers.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

use strict;
use warnings;
use Getopt::Long;

my (@dirs, $recursive, $verbose);

my @extensions = ('.ogg', '.mp3', '.mp4', '.mkv', '.avi');

sub print_usage_and_exit
{
    select STDERR;
    print << "EOF";
usage: $0 <options> -- directories

options:
    -r, --recursive: works recursivley
    -v, --verbose  : enable more output
EOF
    return;
}

sub get_args
{
    GetOptions("recursive" => \$recursive,
               "verbose"   => \$verbose) || print_usage_and_exit();
    @dirs = @ARGV;
    print_usage_and_exit() unless @dirs;
    return;
}

sub gen_pls
{
    my ($files_ref, $list) = @_;
    my ($num_entries, $i, $fh) = (scalar @{$files_ref}, 1, undef);

    open($fh, ">", $list) || die "Cannot open playlist $list: $!";
    print "Creating playlist $list...\n" if $verbose;
    print $fh "[playlist]\n";
    print $fh "numberofentries=$num_entries\n";
    foreach my $file (@{$files_ref}) {
        print $fh "File$i=$file\n";
        ++$i;
    }
    close $fh;

    return;
}

sub do_it
{
    my ($dir) = @_;
    my ($dh, $file, @files, @dirs);

    opendir($dh, $dir) || die "Cannot open directory $dir: $!\n";

    while ($file = readdir $dh) {
        next if $file =~ /^\./;
        push @files, $file if (scalar grep { $file =~ /$_$/ } @extensions) > 0;
        push @dirs, "$dir/$file" if -d "$dir/$file";
    }
    closedir $dh;

    @files = sort @files;
    gen_pls(\@files, "$dir/Playlist.pls") if @files;

    if ($recursive) {
        do_it($_) for @dirs;
    }

    return;
}

get_args();
do_it($_) for @dirs;

exit 0;
