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
    'LaTeXML' => '0.8.1',
    'Plack::Test' => 0,
    'HTTP::Request::Common'=>0,
    'URI::Escape'=>0,
    'JSON::XS'=>0
  },
  EXE_FILES => ['script/ltxpsgi'],
  test => {TESTS => 't/*.t'},
  (eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (META_MERGE => {
    'meta-spec' => { version => 2 },
      resources => {
        repository => {
          type => 'git',
          url => 'https://github.com/dginev/LaTeXML-Plugin-ltxpsgi.git',
          web => 'https://github.com/dginev/LaTeXML-Plugin-ltxpsgi',
        }}})
  : ()),
);
