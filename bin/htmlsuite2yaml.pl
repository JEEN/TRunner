#!/usr/bin/env perl
use strict;
use warnings;
use Web::Query;
use Path::Class;
use Data::Dumper;
use YAML;

die "Usage: perl htmlsuite2yaml.pl [htmlsuite.html]" unless $ARGV[0];

my $file = Path::Class::File->new($ARGV[0]);

die "404 Not Found(!)" unless -f $file;

my $base_dir = $file->dir;
my $html = $file->slurp( iomode => '<:encoding(utf8)' );

my $wq = Web::Query->new_from_html($html);

my $dataset;

$wq->find('tr')->each(sub {
  my ($i, $elm) = @_;

  return unless $i;
  my $case = $elm->find('td');
  my $case_link = $case->find('a')->attr('href');
  my $case_name = $case->text;
  my $case_file = Path::Class::File->new(sprintf '%s/%s', $base_dir, $case_link);
  my $case_name_for_key = sprintf '%03d_%s', $i, $case_name;
  push @{ $dataset->{TestSuite} }, [ $case_name, $case_name_for_key ];
  my $case_html = $case_file->slurp( iomode => '<:encoding(utf8)' );
  my $c_wq = Web::Query->new_from_html($case_html);
  $dataset->{TestCase}->{$case_name_for_key}->{title} = $case_name;

  $c_wq->find('tbody>tr')->each(sub {
     my ($j, $celm) = @_;

     push @{ $dataset->{TestCase}->{$case_name_for_key}->{tests} }, [ grep { $_ } $celm->find('td')->text ];
  });
});

print YAML::Dump $dataset;
