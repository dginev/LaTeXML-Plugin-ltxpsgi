use strict;
use warnings;

my $eval_return = eval {use LaTeXML::Util::TestPSGI; 1;};
ok($eval_return && !$@, 'TestPSGI Loaded successfully.');
done_testing();