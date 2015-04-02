# -*- CPERL -*-
#**********************************************************************
# Test cases for LaTeXML Client-Server processing
#**********************************************************************
use LaTeXML::Util::TestPSGI;

# For each test $name there should be $name.xml and $name.log
# (the latter from a previous `good' run of 
#  latexmlc {$triggers} $name
#).

psgi_tests('t/daemon/profiles',
        requires=>{fragment=>'dvipsnam.def',math=>'dvipsnam.def'});
#**********************************************************************
1;
