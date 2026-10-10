#!/usr/bin/env perl
#
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Copyright (C) 2015-2026 Kurt Kanzenbach <kurt@kmk-computers.de>
#

use strict;
use warnings;
use Getopt::Long;

my (@dirs, $recursive, $verbose);

my @extensions = ('.ogg', '.mp3', '.mp4', '.mkv', '.avi', '.webm');

sub print_usage_and_exit
{
    select STDERR;
    print << "EOF";
usage: $0 <options> -- directories

options:
    -r, --recursive: works recursivley
    -v, --verbose  : enable more output
EOF
    exit -1;
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
