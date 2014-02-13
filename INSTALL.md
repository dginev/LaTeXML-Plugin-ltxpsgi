## Installing ltxPSGI - a minimal, robust web service for LaTeXML

This manual assumes a Debian-based OS.

### Generics

0. On Debian, consider installing the prerequisite Perl packages from the package manager:
```
sudo apt-get install libplack-perl \ 
  libhttp-message-perl \
  liburi-perl \
  libjson-xs-perl \
```

1. Install LaTeXML, as described at [the official LaTeXML installation instructions](http://dlmf.nist.gov/LaTeXML/get.html)

2. Test and (optionally) install ltxPSGI

  ```
  $ git clone https://github.com/dginev/LaTeXML-Plugin-ltxpsgi
  $ cd LaTeXML-Plugin-ltxpsgi
  $ perl Makefile.PL ;  make ; make test
  $ sudo make install
  ```

or via cpanm:
  ```
  $ cpanm git://github.com/dginev/LaTeXML-Plugin-ltxpsgi.git
  ```

### Deployment

The ltxPSGI web service is written in the PSGI specification and can thus
be deployed under any production web-server compatible with PSGI,
 e.g. Apache+mod_perl or Apache+FastCGI.

1. Apache+mod_perl and Plack

  1.1. Install Apache as usual
 
  ```
  $ sudo apt-get install apache2
  ```

  1.2. Install Mod_perl 
  
  ```
  $ sudo apt-get install libapache2-mod-perl2
  ```

  1.3. Install Plack
   
  ```
  $ sudo apt-get install libplack-perl
  ```

  1.4. Make sure you've ran ```make test``` successfully and 
  ltxpsgi can be found in ```blib/script```

  1.5. Grant permissiosn to www-data for the blib/script folder:
  
  ```
  $ sudo chgrp -R www-data /path/to/LaTeXML/blib/script
  $ sudo chmod -R g+w /path/to/LaTeXML/blib/script
  ```

  1.6. Create a "latexml" file in /etc/apache2/sites-available and
  a symbolic link to it in /etc/apache2/sites-enabled

  ```
  <VirtualHost *:80>
      ServerName localhost 
      DocumentRoot /path/to/LaTeXML/blib/script/

      PerlOptions +Parent
                                                                
      <Perl>
        $ENV{PLACK_ENV} = 'production';
      </Perl>

      <Location />
        SetHandler perl-script
        PerlHandler Plack::Handler::Apache2
        PerlSetVar psgi_app /path/to/LaTeXML/blib/script/ltxpsgi
      </Location>

      ErrorLog /var/log/apache2/latexml.error.log
      LogLevel warn
      CustomLog /var/log/apache2/latexml.access.log combined
  </VirtualHost>
  ```

  For providing the requisite paths to profiles of bindings that do not come preinstalled with LaTeXML (namely for the sTeX, PlanetMath, arXMLiv and ZBL setups), set the respective environmental variable in the <Perl> block of the virtual host definition. All profiles add paths pointing to the $LATEXMLINPUTS environment, if defined. Note that all environment names ending in INPUTS may
  contain multiple directories, separated in the usual way via colons(:).

  Example setting all environments used in profiles thus far:
  
  ```
  <Perl>
    $ENV{PLACK_ENV} = 'production';
    $ENV{LATEXMLINPUTS} = '/first/path/to/custom/inputs:/second/path:/third/path:etc/etc/etc'
    $ENV{STEXSTYDIR} = '/path/to/stex/sty/directory'
    $ENV{ZBLINPUTS} = '/path/to/zbl/sty/'
    $ENV{PLANETMATHINPUTS} = '/path/to/planetmath/sty'
    $ENV{ARXMLIVINPUTS} = '/path/to/arxmliv/sty'
  </Perl>
  ```

2. Standalone

```
plackup blib/script/ltxpsgi
```
