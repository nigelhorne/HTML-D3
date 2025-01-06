use strict;
use warnings;
use ExtUtils::MakeMaker;

my $dist = {
	COMPRESS => 'gzip -9f', # Compress tarball using gzip
	SUFFIX => 'gz',	# File suffix for tarball
};

if($^O eq 'darwin') {
	$dist->{'TAR'} = 'gtar';
}

WriteMakefile(
	NAME => 'D3::Chart',
	VERSION_FROM => 'lib/D3/Chart.pm', # finds $VERSION in the module
	AUTHOR => 'Nigel Horne <njh@bandsman.co.uk>',
	ABSTRACT => 'A simple Perl module for generating bar charts using D3.js',
	LICENSE => 'perl',
	PREREQ_PM => {
	'ExtUtils::MakeMaker' => 6.64,	# Minimum version for TEST_REQUIRES
		'JSON' => 0, # Required for encoding data to JSON
	}, dist => $dist,
	clean	 => {
		FILES => 'D3-Chart-*',
	},
);
