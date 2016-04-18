use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Dancer2::Template::TemplateFlute',
    AUTHOR              => q{Stefan Hornburg (Racke) <racke@linuxia.de>},
    VERSION_FROM        => 'lib/Dancer2/Template/TemplateFlute.pm',
    ABSTRACT_FROM       => 'lib/Dancer2/Template/TemplateFlute.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Dancer2' => 0,
        'Template::Flute' => 0.0140,
        'Data::Transpose' => 0.0006,
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/racke/Dancer2-Template-TemplateFlute.git',
                web  => 'https://github.com/racke/Dancer2-Template-TemplateFlute',
                bugtracker  => 'https://github.com/racke/Dancer2-Template-TemplateFlute/issues',
            },
        },
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Dancer2-Template-Template-Flute-*' },
);
