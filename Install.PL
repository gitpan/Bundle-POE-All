#!/usr/bin/perl

# Standard stuff to catch errors
use strict qw(subs vars refs);				# Make sure we can't mess up
use warnings FATAL => 'all';				# Enable warnings to catch errors

# CPANPLUS stuff we need
use CPANPLUS::Backend;
use CPANPLUS::Configure;

# Okay, get all the distributions that are POE :)
my $CPAN = CPANPLUS::Backend->new( CPANPLUS::Configure->new() );

my $search = $CPAN->search( 'type' => 'module', 'list' => [ "^POE::" ] );

# Okay, build the master list of packages to install
my %packages;
foreach my $module ( sort keys %$search ) {
	# Grab the package name
	my( $pkg, $ver ) = ( $search->{ $module }->package() =~ /^(.*?)-([0-9\.\_]+)(?:\.tar\.gz|\.tgz)$/ );

	# Skip malformed packages or whatnot
	if ( ! defined $pkg ) {
		warn "Skipping $module -> unable to parse it...\n";
		next;
	}
	
	# If it's POE, skip it :)
	if ( $pkg eq 'POE' ) { next }

	# Put this information in the master list
	if ( exists $packages{ $pkg } ) { next }
	$packages{ $pkg } = $search->{ $module };
}

# Okay, remove packages that are already installed
foreach my $module ( sort keys %packages ) {
	# Ask CPANPLUS if it is up-to-date
	my $installed = $packages{ $module }->uptodate();

	# If It's not installed, will be undef
	# If installed, will be hashref
	if ( defined $installed and $installed->{'uptodate'} ) {
		# This module is installed and up-to-date, skip it
		warn "Skipping $module -> Already installed with version $installed->{'version'}\n";
		delete $packages{ $module };
	}
}

# Okay, install them all!
foreach my $module ( sort keys %packages ) {
	$packages{ $module }->install();
}

# All done!
exit 0;
