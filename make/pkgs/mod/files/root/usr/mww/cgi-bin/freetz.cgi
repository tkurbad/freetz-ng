#!/bin/sh


PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi --id=freetz

# (svn log --quiet | sed -rn 's/^r[^|]*.([^|]*).*/\1/p' ; echo -e 'Er4twXz\nMcBane87\nTobjasR\nL3P3\nhermann72pb\njohnbock\nM66B\nmagenbrot\nreiffert\nsf3978') | sed 's/(.*)//g;s/ //g' | sort -u | grep -vE '^(root|administrator|github-actions|dependabot\[bot\]|fda77|oliver|derheimi|sfritz|SvenLuebke)$' 
cgi_begin "$(lang de:"&Uuml;ber" en:"About")"
cat << EOF | sed -r 's/(.+[^>])$/\1<br>/g'
<center>

<p>
<h1>Supporters</h1>
abraXxl
aholler
AldoB.
Alex
asmcc
berndy2001
Bodenseematze
BojanSofronievski
buehmann
BugReporter-ilKY
cawidtu
ChihabDjaidja
cinereous
cm8
Conan179
cuma
dionysius
Dirk
e6e7e8
EnricoGhera
er13
Er4twXz
f-666
feedzapper
fesc2000
fidelio-dev
flosch-dev
forenuser
FriederBluemle
Greg57070
GregoryAUZANNEAU
Grische
GulDukat
Hadis
harryboo
HerbertNowak
hermann72pb
Himan2001
hippie2000
horle
id1508
idealist1508
Ircama
JanpieterSollie
JasperMichalke
JBBgameich
Jens
jer194
johnbock
kriegaex
L3P3
leo22
lherschi
LizenzFass78851
M66B
magenbrot
ManfredMueller
Marcel
markuschen
MartenRingwelski
martinkoehler
Maurits
MaxMuster
maz
McBane87
McNetic
MichaelHeimpold
mickey
mike
milahu
MilanHauth
mrtnmtth
Oliver
openfnord
PeterFichtner
PeterKowalsky
PeterMeiser
PeterPawn
Rainer
ralf
ralfhartmann
reiffert
RolfLeggewie
SaMMy-lacht
SebastianErtz
sf3978
sfritz2
smischke
stblassitude
SvenLübke
telsch
thiloms
TobjasR
uwes-ufo
Whoopie
WileC
wmhdhm
</p>

</center>
EOF
cgi_end

