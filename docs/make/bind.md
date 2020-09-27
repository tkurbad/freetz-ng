# BIND 9.11.22

Mit [bind](http://isc.org/software/bind) (Berkeley
Internet Name Daemon) kann ein DNS-Server zur IP- und Namensauflösung
betrieben werden.



### named.conf

Die möglichen Optionen können der Manpage oder den vielen Internetseiten
entnommen werden.

Minimal *named.conf*:

```
options {
    directory "/var/media/ftp/uFlash/bind";
    listen-on port 53 { any; };
    allow-query { any; };
    notify no;
};

zone "example.org" in {
      type master;
      file "example.org";
};
```

Minimal zone file */var/media/ftp/uFlash/bind/example.org*:

```
$TTL 300
@       IN      SOA     @ example.org. (
                        2011032701      ;serial
                        300             ;refresh
                        300             ;retry
                        300             ;expire
                        300             ;minimum
                        )

        IN      NS      ns.example.org.
*       IN      A       85.214.209.234
```
