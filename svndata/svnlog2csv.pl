#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

# Defaults.
$output = "byfile";
$header = 1;

# Process command line args.
for( $i=0; $i<=$#ARGV; $i++ ) {
    if( $ARGV[$i] eq "-output_style" ) {
        $i++;
        $output = $ARGV[$i];
    } elsif( $ARGV[$i] eq "-no_header" ) {
        $header = 0;
    } elsif( $ARGV[$i] eq "-repo" ) {
        $i++;
        $repo = @ARGV[$i];
    } elsif( $ARGV[$i] eq "-file" ) {
        $i++;
        $file = @ARGV[$i];
    }
}

# Usage error.
if( ( $output !~ /^summary$|^byfile/ ) ||
    ( ! $repo ) ||
    ( ! $file )
) {
    die( "Usage: $0 [-noheader] [-output_style <summary|byfile>] <-repo repo> <-file file>\n" );
}
# Print the header.
if( $header ) {
    if( $output eq "summary" ) {
        push( @output, "revision\|login\|datetime\|filecnt\|crids\|repo\|branch\n" );
    } else {
        push( @output, "revision\|login\|datetime\|action\|file\|repo\|branch\n" );
    }
}

# Read in each line of the svn log data file.
open( F, $file );
while( <F> ) {
    chomp();
    if( /^------------------------------------------------------------------------$/ ) {
        $start = 1;
        $section = "header";
        # Push the record to the output.
        # First figure out the branch by evaluating which branch was changed the
        # most in the file list.
        if( $revision ) {
            for $key ( sort( keys( %branchcnt ) ) ) {
                if( $branchcnt{$key} > $maxbranchcnt ) {
                    $branch = $key;
                    $maxbranchcnt = $branchcnt{$key};
                }
            }
            if( $output eq "summary" ) {
                push( @output, "$revision\|$login\|$date $time $tzoffset\|$filecnt\|$crids\|$repo\|$branch\n" );
            } elsif( $output eq "byfile" ) {
		    for $file ( sort( keys( %files ) ) ) {
			push( @output, "$revision\|$login\|$date $time $tzoffset\|$files{$file}\|$file\|$repo\|$branch\n" );
		    }
            }
        }
        $comma = "";
        $crids = "";
        $branch = "";
        $maxbranchcnt = 0;
        %branchcnt = ();
        %crids = ();
        $filecnt = 0;
        %files = ();
    } elsif( /^r(\d+) \| (\S+) \| (\d\d\d\d-\d\d-\d\d) (\d\d:\d\d:\d\d) (\S+)/ && $section eq "header" ) {
        $revision = $1;
        $login = $2;
        $date = $3;
        $time = $4;
        $tzoffset = $5;
        $section = "paths";
    } elsif( /^Changed paths:$/ && $section eq "paths" ) {
        next;
    } elsif( /^   (\S+) (\/.*)/ && $section eq "paths" ) {
        $action = $1;
        $file = $2;
        $files{$file} = $action;
        if( $file =~ /^\/trunk/ ) {
            $branch = "trunk";
        } elsif( $file =~ /^\/branches\/([^\/]+)/ ) {
            $branch = $1;
        } elsif( $file =~ /^\/tags/ ) {
            $branch = "tag";
        } else {
            $branch = "unknown";
        }
        $branchcnt{$branch}++;
        $filecnt++;
    } elsif( /^$/ && $section eq "paths" ) {
        $section = "description";
    } elsif( $section eq "description" ) {
        @words = split( /[ ,:]/ );
    }
}
close( F );
print @output;
