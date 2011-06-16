#!/usr/bin/env perl
package yml2htmlsuite;
# ABSTRACT: selenium yaml file to html files converter
use strict;
use warnings;
use utf8;
use Pod::Usage;
use Getopt::Long;
use File::Basename;
use Catalyst::Helper;
use Carp qw/confess/;
use YAML::XS qw/Load LoadFile/;

my %options;
GetOptions(\%options, "--output=s", "--help");

run(\%options, @ARGV);

sub run {
    my($opts, @args) = @_; 

    pod2usage(0) if ($opts->{help});

    render_files($opts, @args);
}

sub render_files {
    my ($opts, @args) = @_;

    my $helper = Catalyst::Helper->new;
    if (@args == 0 or $args[0] eq '-') {
        my $content = join '', <STDIN>;
        my $yml = Load($content);
        render_case($opts, $helper, $yml);
        render_suite($opts, $helper, $yml);
    } else {
        for my $file (@args) {
            confess "File not found" unless -f $file;

            my $yml = LoadFile($file);
            render_case($opts, $helper, $yml);
            render_suite($opts, $helper, $yml);
        }
    }
}

sub render_case {
    my ($opts, $helper, $yml) = @_;

    my $output = '';
    if ($opts->{output}) {
        my ($filename, $dir, $suffix) = fileparse($opts->{output});
        $output = "$dir$filename/";
    }

    for my $arrRef (@{ $yml->{TestSuite} }) {
        my @suite = @{$arrRef};
        $yml->{TestCase}{$suite[1]}{base} = $yml->{base};
        $helper->render_file( 'TestCase', $output . "$suite[0].html", $yml->{TestCase}{$suite[1]} );
    }
}

sub render_suite {
    my ($opts, $helper, $yml) = @_;

    my $output = '';
    if ($opts->{output}) {
        my ($filename, $dir, $suffix) = fileparse($opts->{output});
        $output = "$dir$filename/";
    }

    $helper->render_file( 'TestSuite', $output . 'all.html', $yml );
}

1;

=head1 SYNOPSIS

    yml2htmlsuite.pl [OPTIONS]
      OPTIONS:
        -h, --help      show this message
        -o, --output    directory path

=cut

__DATA__

__TestCase__
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head profile="http://selenium-ide.openqa.org/profiles/test-case">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="selenium.base" href="[% base %]" />
<title>[% title %]</title>
</head>
<body>
<table cellpadding="1" cellspacing="1" border="1">
<thead>
<tr><td rowspan="1" colspan="3">[% title %]</td></tr>
</thead><tbody>
[% FOREACH test IN tests -%]
<tr>
	<td>[% test.0 | html %]</td>
	<td>[% test.1 | html %]</td>
	<td>[% test.2 | html %]</td>
</tr>
[% END -%]

</tbody></table>
</body>
</html>

__TestSuite__
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <meta content="text/html; charset=UTF-8" http-equiv="content-type" />
  <title>Test Suite</title>
</head>
<body>
<table id="suiteTable" cellpadding="1" cellspacing="1" border="1" class="selenium"><tbody>
<tr><td><b>Test Suite</b></td></tr>
[% FOREACH test IN TestSuite -%]
<tr><td><a href="[% test.0 %].html">[% test.0 %]</a></td></tr>
[% END -%]
</tbody></table>
</body>
</html>
