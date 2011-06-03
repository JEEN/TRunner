use strict;
use warnings;
use Test::More;
plan tests => 2;
use_ok("TRunner::Bridge::Smolder::Uploader");

my $r = TRunner::Bridge::Smolder::Uploader->new(
    server => 'your server',
    username => 'username',
    password => 'password',
    project_id => 2,
    file => 'files.tar.gz',
);

is($r->upload, 1, "DONE");

done_testing();

