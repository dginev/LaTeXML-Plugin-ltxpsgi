#======================================================================
# Makefile Maker for ltxMojo - LaTeXML's web service
# d.ginev@jacobs-university.de
#======================================================================
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME => 'LtxPSGI',
  AUTHOR => 'Deyan Ginev <d.ginev@jacobs-university.de>',
  ABSTRACT => "ltxPSGI - A headless PSGI web service for LaTeXML",
  VERSION_FROM => 'script/ltxpsgi',
  PREREQ_PM => {
    'LaTeXML' => '0',
    'Plack::Test' => 0,
    'HTTP::Request::Common'=>0,
    'URI::Escape'=>0,
    'JSON::XS'=>0
  },
  EXE_FILES => ['script/ltxpsgi'],
  test => {TESTS => 't/*.t'}
);
