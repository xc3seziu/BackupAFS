#============================================================= -*-perl-*-
#
# BackupAFS::CGI::LOGlist package
#
# DESCRIPTION
#
#   This module implements the LOGlist action for the CGI interface.
#
# AUTHOR
#   Craig Barratt  <cbarratt@users.sourceforge.net>
#
# COPYRIGHT
#   Copyright (C) 2003-2009  Craig Barratt
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 3 ONLY.
#   
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#========================================================================
#
# Version 1.0.8, released 15 Sep 2015.
#
# See http://backupafs.sourceforge.net.
#
#========================================================================

package BackupAFS::CGI::LOGlist;

use strict;
use BackupAFS::CGI::Lib qw(:all);

sub action
{
    my $Privileged = CheckPermission($In{volset});

    if ( !$Privileged ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_log_files});
    }
    my $volset = $In{volset};
    my($url0, $hdr, @files, $str);
    if ( $volset ne "" ) {
        $url0 = "&volset=${EscURI($volset)}";
        $hdr = "for volset $volset";
    } else {
        $url0 = "";
        $hdr = "";
    }

    foreach my $file ( $bafs->sortedPCLogFiles($volset) ) {
        my $url1 = "&num=$1" if ( $file =~ /LOG\.(\d+)(\.z)?$/ );
        $url1    = "&num="   if ( $file =~ /LOG(\.z)?$/ );
        next if ( !-f $file );
        my $mtimeStr = $bafs->timeStamp((stat($file))[9], 1);
        my $size     = (stat($file))[7];
        (my $fStr    = $file) =~ s{.*/}{};
        $str .= <<EOF;
<tr><td> <a href="$MyURL?action=view&type=LOG$url0$url1"><tt>$fStr</tt></a></td>
    <td align="right"> $size </td>
    <td> $mtimeStr </td></tr>
EOF
    }
    my $content = eval("qq{$Lang->{Log_File_History__hdr}}");
    Header($Lang->{BackupAFS__Log_File_History},
                $content, !-f "$TopDir/volsets/$volset/backups");
    Trailer();
}

sub compareLOGName
{
    #my($a, $b) = @_;

    my $na = $1 if ( $a =~ /LOG\.(\d+)/ );
    my $nb = $1 if ( $b =~ /LOG\.(\d+)/ );

    if ( length($na) >= 5 && length($nb) >= 5 ) {
        #
        # Both new style.  Bigger numbers are more recent.
        #
        return $nb <=> $na;
    } elsif ( length($na) >= 5 && length($nb) < 5 ) {
        return -1;
    } elsif ( length($na) < 5 && length($nb) >= 5 ) {
        return 1;
    } else {
        #
        # Both old style.  Smaller numbers are more recent.
        #
        return $na - $nb;
    }
}


1;
