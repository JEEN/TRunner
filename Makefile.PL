use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'TRunner',
    AUTHOR              => q{Jeen Lee <aiatejin@gmail.com>},
    VERSION_FROM        => 'lib/TRunner.pm',
    ABSTRACT            => 'Dynamic Selenium Core TestRunner',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'YAML'       => 0,
        'YAML::XS'   => 0,
        'Dancer'     => 1.3051,
        'Dancer::Template::TemplateToolkit' => 0,
        'Any::Moose' => 0,
        'namespace::autoclean' => 0,
        'HTTP::BrowserDetect' => 0,
        'LWP::UserAgent' => 0,
        'Web::Query' => 0,
        'Archive::Tar' => 0,
        'Try::Tiny' => 0,
        'WWW::Mechanize' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'TRunner-*' },
);
