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
        'Dancer'     => 1.3051,
        'Dancer::Template::Xslate' => 0,
        'Text::Xslate' => 0,
        'Text::Xslate::Bridge::TT2' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'TRunner-*' },
);
