# Copyright (c) 1997-2002 XAO Inc.
###############################################################################
use ExtUtils::MakeMaker;
use ExtUtils::Manifest;

##
# Reading configuration
#
my %d;
if(open(F,'.config')) {
    local($/);
    my $t=<F>;
    close(F);
    eval $t;
}
while(!$d{test_dsn}) {
    print <<EOT;

XAO Content will need access to a XAO::FS database in order to run tests.
That database will be COMPLETELY DESTROYED AND OVERRIDEN every time you
run 'make test'.

The database have to be created, but it does not matter what it contains.

Please enter access information (brackets contain default values), entering
'none' will disable tests:

EOT
    my $dsn='none';
    print "DSN: [$dsn] ";
    chomp(my $str=<STDIN>);
    if($str) {
        if($str =~ /^\s*(OS:(\w+):(\w+)(;.*?)?)\s*$/) {
            $dsn=$1;
        }
        else {
            die "Incorrect DSN entered!\n";
        }
    }
    my $user='';
    my $pass='';
    my $confirm='n';

    if($dsn eq 'none') {
        $confirm='y';
        print <<EOT;

Ok, tests will be skipped per your request.

EOT
    }
    else {
        chomp($user=`whoami`);
        print "User name: [$user] ";
        chomp($str=<STDIN>);
        if($str && $str=~/^\s*(.*?)\s*$/) {
            $user=$1;
        }
        print "Password: [$pass] ";
        chomp($str=<STDIN>);
        if($str && $str=~/^\s*(.*?)\s*$/) {
            $pass=$1;
        }

        print <<EOT;

Here is what will be used to connect to the test database
(and DESTROY it):
   DSN:      $dsn
   User:     $user
   Password: $password

EOT
        $|=1;
        print "Does it make sense ? [Y/n] y\b";
        chomp($confirm=<STDIN>);
    }

    if(!$confirm || lc($confirm)=~/y/) {
        open(F,">.config") || die "Can't open .config: $!\n";
        print F <<EOT;
## Feel free to remove or edit that file. It will be re-created on `perl
## Makefile.PL' if removed.
\$d{test_dsn}='$dsn';
\$d{test_user}='$user';
\$d{test_password}='$pass';
EOT
        last;
    }
}

WriteMakefile(
    'AUTHOR'         => 'Andrew Maltsev, XAO Inc. <am@xao.com>',
    'ABSTRACT'       => 'XAO::Web plugin for managing dynamic content',
    'NAME'           => 'XAO::DO::Web::Content',
    'DISTNAME'       => 'XAO-Content',
    'VERSION_FROM'   => 'Content.pm',
    'PREREQ_PM'      => {
        'XAO::FS'       => '1.03',
        'XAO::Web'      => '1.03',
    }
);

sub MY::postamble
{ <<EOT;
config::	README

README:	Content.pm
	pod2text Content.pm > README

install::
	\$(PERL) -MXAO::PluginUtils=install_templates \\
		 -e'install_templates("MANIFEST",1)'
	\@echo
	\@echo "Please read the XAO::DO::Web::Content manpage"
	\@echo "for usage instructions."
	\@echo
	\@echo "Good luck!"
	\@echo
EOT
}