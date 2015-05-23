use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::Statsd',
  VERSION_FROM => 'lib/Mojolicious/Plugin/Statsd.pm',
  AUTHOR       => 'Meredith Howard <mhoward@cpan.org>',
  PREREQ_PM    => {
    'Mojolicious'    => '6.00'
    'Test::Warnings' => '0.021'
  },
  test         => {TESTS => 't/*.t'}
);
