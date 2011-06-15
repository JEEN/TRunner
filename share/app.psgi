#!/usr/bin/env perl
package app;
# ABSTRACT: app.psgi
use Dancer;
use TRunner;
use Plack::Builder;
use File::ShareDir qw/dist_dir/;
my $app = dance;

builder {
   my $dist_dir = dist_dir('TRunner');
   # enable "Static", path => qr{\.(html|css|js|png|jpg|gif|ico)$/}, root => './public/';
   enable "Static", path => qr{\.(html|css|js|png|jpg|gif|ico)$/}, root => "$dist_dir/public";
   $app;
};

