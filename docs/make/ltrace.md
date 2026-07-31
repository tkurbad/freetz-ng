# ltrace 0.7.3-git/0.8.1 (binary only)
  - Homepage: [https://www.ltrace.org/](https://www.ltrace.org/)
  - Manpage: [https://linux.die.net/man/1/ltrace](https://linux.die.net/man/1/ltrace)
  - Changelog: [https://gitlab.com/cespedes/ltrace/commits/main](https://gitlab.com/cespedes/ltrace/commits/main)
  - Repository: [https://gitlab.com/cespedes/ltrace](https://gitlab.com/cespedes/ltrace)
  - Package: [master/make/pkgs/ltrace/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/ltrace/)
  - Steward: -

**ltrace** ist ein Debug-Tool, mit dem sich von einem Programm ausgelöste "Library Calls" (Bibliotheks-Aufrufe) sowie alle empfangenen Signale monitoren lassen.
Ein vergleichbares Tool findet sich im Paket [strace](strace.md).

### ctlmgr mit ltrace auf den Zahn fühlen
Von @LizenzFass78851 aus [Juis für Geräte ab HWR277](https://github.com/orgs/Freetz-NG/discussions/1415#discussioncomment-17296891)


- avm watchdog ausschalten

```bash
echo disable > /dev/watchdog
```

- Dann den ctlmgr beenden und den Prozess neustarten

```bash
kill -9 $(pidof ctlmgr)
ctlmgr
```

- Dann ausschließlich per http auf die UI der Box gehen bis zum Update Fenster

- Dann eine Vorlage für ltrace erstellen

```bash
nano /var/mod/etc/ltrace.conf
```

Mit folgenden Inhalt **(aktuallisiert)**

```c
int avmssl_write(void*, string, int, void*);
int avmssl_read(void*, +string, int, int);
```

- Dann ltrace starten (getestet mit ltrace 0.8.1)

```bash
ltrace -F /var/mod/etc/ltrace.conf -s 8192 -e avmssl_write+avmssl_read -p $(pidof ctlmgr)
```

- Dann in der Web UI auf Update suchen klicken.

- Dann kommt die Ausgabe


### Weiterführende Links

  - [Repository der alten Version](https://github.com/dkogan/ltrace)


