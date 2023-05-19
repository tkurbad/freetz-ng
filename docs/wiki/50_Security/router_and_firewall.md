# Freetz als interner Router mit Firewall

Diese Anleitung enthält alles was man braucht, um eine FritzBox 7050 mit
freetz in einen internen Router mit Firewall und echter DMZ zu
verwandeln.
Andere Router funktionieren auch, so lange sie mit Linux laufen,
iptables und 2 getrennt ansprechbare Netzwerkschnittstellen haben.
Geräte mit einen Switch, der nur komplett als **ein Interface**
angesprochen werden kann, können keine LAN DMZ (**D**e**M**ilitarized
**Z**one) errstellen. Das WLAN läßt sich aber bei allen Routern,
abtrennen.

### Zielgruppe

Ambitionierte Heimanwender und kleinere bis mittlere Betriebe die ein
extra gesichertes WLAN und/oder Zweitnetzwerk benötigen.

### Beispielszenario

-   Internes Netz1: 192.168.178.0/255.255.255.0 (Anwendernetz)
-   Internes Netz2: 192.168.181.0/255.255.255.0 (Servernetz, echte DMZ)
-   WLAN: 192.168.182.0/255.255.255.0
-   Internetrouter: 192.168.178.1 z.B. weitere Fritzbox, die sich im
    internen Netz befindet und gleichzeitig als DNS Server fungiert.

Wir wollen allen Benutzern des internen Netzes 1 Zugriff auf das
gesammte Netz2 ermöglichen, die WLAN Benutzer sollen aber nur auf das
Internet und bestimmte Dienste in der DMZ zugreifen können. Als Beispiel
nehmen wir einen Webserver, einen Mailserver und einen FTP-Server mit
folgenden Daten:

-   Webserver: IP 192.168.181.5, Ports 80,443
-   Mailserver: IP 192.168.181.6, Ports 25,143,110,993,995
-   FTP-Server: IP 192.168.181.7, Port 21,(20) FTP braucht noch einen
    zusätzlichen Port für den Rückkanal, je nach Modus (aktiv/passiv)

### Die Fritzbox auf getrennte Netze umstellen

Unter *Einstellungen → System → Netzwerkeinstullungen → »IP-Adressen«*
deaktivieren wir nun *Alle Computer befinden sich im selben
IP-Netzwerk*. Damit hat jetzt jedes Interface LAN-A,LAN-B,WLAN,USB sein
eigenes Netz:

[![Einstellungen für separate Netzwerke (Fritz!Box 7050)](../../screenshots/48_md.jpg)](../../screenshots/48.jpg)

### Die Rückrouten

Im Moment können wir zwar Pakete aus unseren DMZ/WLAN ins Internet
verschicken und Pakete von der DMZ ins interne Netz (wird später durch
die Firewall eingeschränkt). Aber unser Internetrouter, der auch Default
Router für alle Rechner ist, kennt unsere neuen Netze noch nicht und
verwirft damit alle Antwortpakete.

Auf Arbeitsrechner marvin (192.168.178.2):

```
    jr@marvin$ ping -c 4 192.168.181.1
    PING 192.168.181.1 (192.168.181.1) 56(84) bytes of data.

    --- 192.168.181.1 ping statistics ---
    4 packets transmitted, 0 received, 100% packet loss, time 2999ms
```

Wir müssen also noch die Rückrouten auf unserem **Internetrouter**
einrichten.

Beispiel Linux Router:

```
    route add -net 192.168.181.0 netmask 255.255.255.0 gw 192.168.178.14
    route add -net 192.168.182.0 netmask 255.255.255.0 gw 192.168.178.14
    route add -net 192.168.179.0 netmask 255.255.255.0 gw 192.168.178.14
```

Beispiel Fritzbox:

Unter *Einstellungen → System → Netzwerkeinstellungen → »IP-Routen«*
wählen wir *»Neue Route«*:

[![Fritzbox: Route hinzufügen](../../screenshots/49_md.jpg)](../../screenshots/49.jpg)

```
	Aktiv     Netzwerk    Subnetzmaske    Gateway
	X   192.168.181.0   255.255.255.0   192.168.178.14 #LANB
	X   192.168.182.0   255.255.255.0   192.168.178.14 #WLAN
	X   192.168.179.0   255.255.255.0   192.168.178.14 #USB
```

Jetzt kommen die Pakete auch wieder zurück. Interessant ist hier die
Redirect-Meldung des Standardgateways, das jetzt den Rechner an unserer
internes Fritzbox verweist.

```
    jr@marvin$ ping 192.168.181.1
    PING 192.168.181.1 (192.168.181.1) 56(84) bytes of data.
    From 192.168.178.1: icmp_seq=1 Redirect Host(New nexthop: 192.168.178.14)
    64 bytes from 192.168.181.1: icmp_seq=1 ttl=64 time=2.43 ms
    From 192.168.178.1: icmp_seq=2 Redirect Host(New nexthop: 192.168.178.14)
    64 bytes from 192.168.181.1: icmp_seq=2 ttl=64 time=2.43 ms
    64 bytes from 192.168.181.1: icmp_seq=3 ttl=64 time=0.519 ms
    64 bytes from 192.168.181.1: icmp_seq=4 ttl=64 time=0.521 ms
    64 bytes from 192.168.181.1: icmp_seq=5 ttl=64 time=0.523 ms
```

### FIXME kopierter Post

[orginalpost](http://www.ip-phone-forum.de/showpost.php?p=1096655&postcount=22)

> Nachdem was ich gelesen habe brauchst du einen Router mit Firewall.
> Iptables ist die standard Linuxfirewall seit Kernel 2.4, avm hat sich
> aber da was eigenes gestrickt. Als Router kannst du alles nehmen auf
> dem a) Linux läuft b) eine echte Firewall läuft und c) du die
> Firewallregeln veränderen kannst. Damit kannst du also eine **fritzbox
> mit telnet bzw. ssh Zugang benutzen (avm firewall)**, eine mit freetz
> gemoddedte fritzbox(iptables) oder einen Linuxrechner(iptables)
> verwenden. Edit2: Nachdem ich noch etwas getestet habe, habe ich jetzt
> festgestellt, das die avm firewall wohl nur mit dem DSL Interface
> funktioniert. Wir brauchen also iptables.

> Den Linuxrechner halte ich für overkill, da du ja eh eine Fritzbox
> fürs WLAN nehmen willst. Damit du dein eigenes Netz nicht unnötig
> umbauen mußt würde ich eine der 7050er Fritzboxen nehmen und mit Port
> A in dein Netz hängen.

> Ich versuche mal eine Anleitung: (EDIT: irgendwas geht noch nicht
> richtig, siehe unten) Alles ab hier wird jetzt nur noch auf der 7050
> für den Nachbar gemacht:

1.  Die Box braucht erstmal eine interne(=dein Netz) IP, damit du drauf
    zugreifen kannst. 1.Danach bekommt jeder Anschluß ein eigenes Netz
    (siehe Bild1):\
    Webinterface→Einstellungen→System→Netzwerkeinstellungen: Alle
    Computer befinden sich im selben IP-Netzwerk abschalten. Jetzt hat
    jeder Anschluß ein eigenes Netz.
    Wichtig hierbei ist, dass der DHCP Server für das interne Netz aus
    ist, sonst hast 2 DHCP Server, die sich gegenseitig stören.
2.  Die Internetverbindung wird jetzt auf Port A gestellt (siehe Bild2)\
    Der Witz bei der Sache ist, das man DSL Verbindung anwählt und nicht
    Port A, denn dann hat man nicht mehr die verschiedenen Netze.
3.  route hinzufügen:

    ```
		Aktiv     Netzwerk    Subnetzmaske    Gateway
		X   0.0.0.0     0.0.0.0     192.168.178.1
	```

	4a) routen **auf der Internet Fritzbox** hinzufügen

	```
		Aktiv     Netzwerk    Subnetzmaske    Gateway
		X   192.168.181.0   255.255.255.0   192.168.178.14 #LANB
		X   192.168.182.0   255.255.255.0   192.168.178.14 #WLAN
		X   192.168.179.0   255.255.255.0   192.168.178.14 #USB
    ```

4.  Telnet aktivieren\
    Gibt es genug Anleitungen im Forum. Bei den neueren Firmwares sollte
    ein telnet pseudo-Image funktionieren
5.  firewall\
    Im Moment Edit: *So weit hab ich das jetzt mal bei mir getestet und
    ich kann die Box erreichen, DNS geht, auch aus den anderen Netzen.
    \[color=blue\]Das einzige, was jetzt hier noch Probleme macht ist
    das Routing zwischen den Netzen und damit auch ins Internet.
    Irgendwas blockiert das Routing, mit den Einstellungen funktioniert
    es auf einem Linux Rechner (forward ist an)! Vieleicht weiß jemand
    anderes weiter.[color](/color)* Ich hatte einfach die Rückroute auf
    der 2. Fritzbox fürs Internet vergessen(siehe 4a)!


