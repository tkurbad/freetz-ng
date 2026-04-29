# cpulimit 0.2 - DEPRECATED
  - Homepage: [https://github.com/opsengine/cpulimit](https://github.com/opsengine/cpulimit)
  - Manpage: [https://github.com/opsengine/cpulimit#cpulimit](https://github.com/opsengine/cpulimit#cpulimit)
  - Changelog: [https://github.com/opsengine/cpulimit/commits/master](https://github.com/opsengine/cpulimit/commits/master)
  - Repository: [https://github.com/opsengine/cpulimit](https://github.com/opsengine/cpulimit)
  - Package: [master/make/pkgs/cpulimit/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/cpulimit/)
  - Steward: -

Usage examples:
```
  Limit process by PID:
    cpulimit -p 1234 -l 50
  
  Launch and limit command:
    cpulimit -l 25 -- /mod/usr/bin/rtorrent
  
  Limit by process name:
    cpulimit -e rtorrent -l 30
```

