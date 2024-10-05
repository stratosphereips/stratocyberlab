#!/usr/bin/perl

=pod
tcpdump-colorize 1.0
Nicolas Martyanoff <khaelin@gmail.com>
This script is in the public domain.
=cut

use strict;
use warnings;

my $hex = qr/[0-9a-f]/;

my $fqdn = qr/(?:[A-Za-z\d\-\.]+\.[a-z]+)/;
my $ipv4_addr = qr/(?:(?:\d{1,3}\.){3}\d{1,3})/;
my $ipv6_grp = qr/$hex{1,4}/;
my $ipv6_addr = qr/(?:::)?(?:${ipv6_grp}::?)+${ipv6_grp}(?:::)?/;
my $ipv6_rev = qr/(?:(?:$hex\.){31}$hex)/;
   $ipv6_addr = qr/(?:$ipv6_addr|$ipv6_rev)/;
my $port = qr/(?:\d{1,5}|[a-z\d\-\.]+)/;

while (<STDIN>) {
    if (m/^((?:[\d\-]+\s)?[\d:\.]+ )?([A-Z0-9]{2,}(?: \d+\.[\da-z]+(?=,))?)([ ,].*)/) {
        my $timestamp = $1;
        my $protocol = $2;
        $_ = "$3\n";

        print "\e[32m$timestamp\e[0m " if $timestamp;
        print "\e[33m$protocol\e[0m";
    }

    # Numeric IPV6 address and port
    s/ $ipv6_addr\.\K$port(?=[ :,])?/\e[36m$&\e[0m/g;
    s/(?<!seq) \K$ipv6_addr(?=[ :,])?/\e[96m$&\e[0m/g;

    # Numeric IPV4 address and port
    s/ $ipv4_addr\.\K$port(?=[ :,])?/\e[36m$&\e[0m/g;
    s/(?<= )$ipv4_addr(?=[ :,])?/\e[96m$&\e[0m/g;

    # FQDN
    s/ $fqdn\.\K$port(?=[ :,])?/\e[36m$&\e[0m/g;
    s/(?<= )$fqdn(?=[ :,])?/\e[97m$&\e[0m/g;

    # Bridge
    s/(?<= )($port)\.($ipv4_addr|$ipv6_addr)\.($port)(?=[ :,])/\e[36m$1\e[0m.\e[34m$2\e[0m.\e[36m$3\e[0m/g;
    s/(?<= )($port)\.($ipv4_addr|$ipv6_addr)(?=[ :,])/\e[36m$1\e[0m.\e[34m$2\e[0m/g;

    # Packet data (tcpdump -x)
    s/\s+0x$hex+(?=:)/\e[35m$&\e[0m/;

    # Warnings
    s/\[bad udp cksum[^\]]*\]/\e[31m$&\e[0m/;

    print;
}
