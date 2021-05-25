# mkwinpe - WinPE für OPSI


## Motivation

Für die Installation von *Windows (10)* mit **OPSI** wird eine WinPE-Umgebung benötigt.  
Diese kann gemäss [Dokumentation](https://download.uib.de/opsi4.2/documentation/html/opsi-getting-started-v4.2/opsi-getting-started-v4.2.html#opsi-getting-started-firststeps-osinstall-fill-base-packages-nt6-pe)
unter Windows erstellt werden.  
Das ist jedoch relativ aufwendig. Zudem verursacht das mit dem *ADK* erstellte WinPE
auf einigen Clients Probleme. Es bietet sich daher die Verwendung des zur jeweiligen
Windows-Version gehörigen WinPE an.

Das vorliegende Skript soll die Erstellung der WinPE-Umgebung vereinfachen. Als 'Bonus'
übernimmt es zudem das Entpacken des ISO-Images.


## Voraussetzungen

Zum Entpacken des ISO-Image kommt 7zip (`7z`) zum Einsatz. Unter Debian/Ubuntu sollte
hierfür das Paket **p7zip-full** installiert sein.

Für die Modifikation dr *boot.wim* wird `mkwinpeimg` verwendet. Dieses findet sich
unter Debian/Ubuntu im Paket **wimtools**.

`mkwinpe.sh` muss im Verzeichnis des NetBoot-Produktes aufgerufen werden, für das 
das ISO-Image entpackt und die WinPE-umgebung erstellt werden soll.


## Anwendung

Das Skipt kann ohne Parameter aufgerufen werden. In diesem Fall fragt es nach dem
zu verwendenden ISO-Image.  
Alternativ kann als Parameter der (relative) Pfad zum zu verwendenden ISO-File übergegben
werden, z.B.:
```sh
mkwinpe.sh iso/SW_DVD9_Win_Pro_10_21H1_64BIT_English_Pro_Ent_EDU_N_MLF_X22-55036.ISO
```

Sollen die bestehenden `installfiles` verwendet werden, wird kein ISO-Image angegeben.

Ist `installfiles` bzw. `winpe` nicht leer, fragt das Skript nach, was zu tun ist.


## ToDo

Die [Erweiterung eines PE](https://download.uib.de/opsi4.2/documentation/html/opsi-getting-started-v4.2/opsi-getting-started-v4.2.html#opsi-getting-started-firststeps-osinstall-fill-base-packages-nt6-extendpe)
um Treiber erfordert momentan noch die Zuhilfenahme von Windows für den Einsatz
von `dism /Add-Driver`.  
Ziel ist es, die Treiber auch ohne den Umweg über Windows direkt auf dem OPSI-Server
zu integrieren.


-----
Jens Boettge <<boettge@mpi-halle.mpg.de>>, 2021-05-25 09:55:24 +0200
