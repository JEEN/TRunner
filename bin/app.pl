#!/usr/bin/env perl
use Dancer;
use TRunner;
use Plack::Builder;
my $app = dance;

builder {
   enable "Static", path => qr{\.(html|css|js|png|jpg|gif|ico)$/}, root => './public/';
   $app;
};

