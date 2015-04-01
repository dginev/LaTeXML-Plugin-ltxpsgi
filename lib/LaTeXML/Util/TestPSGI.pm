package LaTeXML::Util::TestPSGI;
use strict;
use warnings;

use Plack::Test;
use Test::More;
use LaTeXML::Util::Test;

use HTTP::Request::Common;
use LaTeXML::Util::Pathname;

use URI::Escape;
use JSON::XS;
use Data::Dumper;

use FindBin;
our $psgi_app = require("$FindBin::Bin/../blib/script/ltxpsgi");
our @ISA = qw(Exporter);
our @EXPORT = (qw(psgi_ok psgi_tests),
         @Test::More::EXPORT);

sub psgi_ok {
  my($base,$dir,$generate)=@_;
  my $localname = $base;
  $localname =~ s/$dir\///;
  my $opts = LaTeXML::Util::Test::read_options("$base.spec");
  push @$opts, (
    ['log', "/dev/null"],
    ['destination', "$localname.test.xml"],
    ['timeout',5],
    ['autoflush',1],
    ['base',pathname_absolute($dir,pathname_cwd())],
    ['timestamp','0'],
    ['nodefaultresources',''],
    ['xsltparameter','LATEXML_VERSION:TEST'],
    ['nocomments', ''] );
  my $body = '';
  my $timed = undef;
  SKIP: {
  foreach my $opt(@$opts) {
    if ($$opt[0] eq 'timeout') { # Ensure .opt timeout takes precedence
      if ($timed) { next; } else {$timed=1;}
    }
    if ($$opt[0] eq 'source') {
      if (pathname_protocol($$opt[1]) eq 'file') {
        skip("Ignoring file system test (source is $$opt[1])",1);
      }
    }
    $body.= $$opt[0] . '=' . (length($$opt[1]) ? uri_escape($$opt[1]) : '') . '&';
  }
  chop $body; # remove trailing ampersand
  if (!$generate) {
    #print STDERR Dumper($body);
    test_psgi app=>$psgi_app, client => sub {
      my $cb  = shift;
      my $res = decode_json($cb->(POST "/", Content => $body)->content);
      my $result_strings = [ split("\n",($res->{result}||'')) ];
      $result_strings = [''] unless scalar(@$result_strings);
      is_strings($result_strings,
                  LaTeXML::Util::Test::get_filecontent("$base.xml"),"PSGI app: $base\n".Dumper($res));
      unlink "$base.test.xml" if -e "$base.test.xml";
      unlink "$base.test.status" if -e "$base.test.status";
    };
  }
  else {
    #TODO: Skip 3 tests
  }}
}

sub psgi_tests {
  my($directory,%options)=@_;

  if(!opendir(DIR,$directory)){
    # Can't read directory? Fail (assumed single) test.
    do_fail($directory,"Couldn't read directory $directory:$!"); }
  else {
    my @dir_contents = sort readdir(DIR);
    my @core_tests   = grep(s/\.tex$//, @dir_contents);
    my @daemon_tests = grep(s/\.spec$//, @dir_contents);
    closedir(DIR);
    eval { use_ok("LaTeXML"); }; # || skip_all("Couldn't load LaTeXML"); }

  SKIP:{
    my $requires = $options{requires} || {}; # normally a hash: test=>[files...]
    if(!ref $requires){ # scalar== filename required by ALL
      LaTeXML::Util::Test::check_requirements("$directory/",$requires); # may SKIP:
      $requires={}; }   # but turn to normal, empty set
    elsif($$requires{'*'}){
      LaTeXML::Util::Test::check_requirements("$directory/",$$requires{'*'}); }

    foreach my $name (@daemon_tests){
      my $test = "$directory/$name";
      SKIP: {
        skip("No file $test.xml and/or $$test.status",1)
          unless ((-f "$test.xml") && (-f "$test.status"));
        next unless LaTeXML::Util::Test::check_requirements($test,$$requires{$name});
        psgi_ok($test,$directory,$options{generate});
      }}}}
  done_testing(); }


1;