#!/usr/bin/env perl

use strict;
use warnings;
use LWP::UserAgent ();
use JSON qw(decode_json);

my $url = 'https://hn.algolia.com/api/v1/search?query=postmortem&tags=story';

my $pages = get(0);
for (my $page=1; $page < $pages; $page++) {
    usleep(0.3);
    get($page);
}

sub usleep {
    my $us = shift;
    select(undef, undef, undef, $us);
}

sub get {
    my $page = shift;
    my $pages = 0;
    
    print "======= page $page ============\n";

    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;
    $ua->agent( "libperl-www" );	# wtf it needs this

    my $response = $ua->get($url . "&page=$page");

    if ($response->is_success) {
	my $har = decode_json $response->decoded_content;
	
	$pages = $har->{nbPages};

	for my $h (@{$har->{hits}}) {
	    if ($h->{url}) {
		print $h->{url}, $/;
	    }
	}
    }
    else {
	die $response->status_line;
    }

    return $pages;
}
