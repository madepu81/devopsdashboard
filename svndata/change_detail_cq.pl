#!/usr/bin/perl

$ENV{LANG} = "en_CA.UTF-8";

$start_date = @ARGV[0];
$end_date = @ARGV[1];
$url = @ARGV[2];
$flag = @ARGV[3];

$url =~ ?http://[^/]+/svn/([^/]+)?;
$repo = $1;

system( "svn log -v -r '{$start_date}:{$end_date}' $url > svnlog.tmp" );
system( "cqperl svn_add_cq.pl $flag -output_style byfile -repo $repo -file svnlog.tmp" );
