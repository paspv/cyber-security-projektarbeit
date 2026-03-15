# Projektarbeit Cyber Security

Projektarbeit im Rahmen des Fachs "Cyber Security" im "Informatiker HF"-Lehrgang an der Teko.

## Inhalt
- [Der Plan](#der-plan)
    - [Testumgebung](#testumgebung)
    - [Zukünftige Pläne](#zukünftige-pläne)

- [Die Ausführung](#die-ausführung)
    - [Lab Environment](#lab-environment)
    - [Ansible](#ansible)
    - [Firewall](#firewall)
    - [Pi-hole](#pi-hole)
    - [VPN](#vpn)
- [Das Resultat](#das-resultat)
    - [Erweiterungspläne](#erweiterungspläne)


## Der Plan

Ich habe schon länger mit dem Gedanken gespielt, meinen alten PC zu einem Home-Server umzubauen, mir hat aber der Anstoss gefehlt, da kommt mir diese Projektarbeit sehr gelegen.

Geplant ist die Installation und Konfiguration folgender Dienste: 

- **Pi-hole:** Zur Blockierung von Werbung in meinem Heimnetzwerk.
- **VPNs:** Zur Verbesserung der Sicherheit, falls ich mal auf öffentliche Hotspots angewiesen sein sollte und auch auf meinen mobilen Geräten vom Pi-hole profitieren kann.
- **Firewall:** Zur Verbesserung der Sicherheit meines Heimnetzwerks.

**Infrastructure as Code:** Zusätzlich habe ich für mich die Anforderung, dass ich diese Dienste automatisiert installieren und konfigurieren können will. Sprich das Hauptprodukt dieser Arbeit werden die Skripts sein, mit denen sich diese Dienste installieren lassen können.

Da ich über keinerlei Erfahrungen mit dem Einrichten dieser Dienste und dem Konzept von Infrastructure as Code habe, habe ich mir zur groben Planung des Projekts ChatGPT zu Hilfe gezogen. 

Ursprünglich war folgende Projektstruktur geplant:

```
cyber-security-projektarbeit/
│
├── ansible/
│   ├── inventories/
│   │   ├── lab.yml
│   │   └── production.yml
│   │
│   ├── roles/
│   │   ├── base/
│   │   ├── docker/
│   │   ├── pihole/
│   │   ├── wireguard/
│   │   └── firewall/
│   │
│   └── site.yml
│
├── docker/
│   ├── pihole/
│   │   └── docker-compose.yml
│   └── reverse-proxy/ (future)
│
└── README.md/
```

Die Automatisierung soll mit Ansible, einer open-source Technologie zur Automatisierung von IT Tasks, durchgeführt werden. ChatGPT hat mir diese Technologie vorgeschlagen, denn damit kann man die Scripts von einem Host aus via SSH automatisch auf den Zielservern ausführen lassen. Leider hat das nicht ganz so gut geklappt wie ich mir das vorgestellt habe, doch dazu in der Ausführung mehr.

### Testumgebung

Wie einigen in der File-Struktur vielleicht bereits aufgefallen ist, sind zwei Environments geplant - `lab` und `production`. Ersteres soll eine VM sein, welche ich auf meinem PC betreibe, während `production` mein Home-Server / alter PC sein wird. Dies vor allem aus dem Grund, weil mein Home-Server noch nicht ganz einsatzbereit ist. Einerseits muss ich noch Speichermedien besorgen, andererseits fehlen mir noch Kabel. Zudem lässt sich eine VM auch einfacher wiederherstellen, wenn etwas nicht ganz klappen sollte.

### Zukünftige Pläne 

Ich möchte den Home-Server so einrichten, dass ich darauf private Webprojekte hosten kann, so dass diese innerhalb des LANs (und via VPN) zugänglich sind. Diese Anforderung ist nicht Teil der Arbeit, hatte aber direkten Einfluss auf die Planung des Projektes.

## Die Ausführung

### Lab-Environment 

Um die Ansible-Skripts zu testen, habe ich mit VirtualBox eine Ubuntu 24.04.4 LTS VM erstellt und diese mit einem Bridge-Adapter in meinem LAN verfügbar gemacht. Um mich mit der VM verbinden zu können, musste hier als erstes SSH installiert werden.

### Ansible

Um die Ansible Skripte ausführen zu können, musste ich das Programm zuerst auf meinem Host-PC (WSL) installieren. 
Damit sich Ansible mit meinem Lab-Environment verbinden konnte, habe ich die folgende Konfiguration erstellt:

> [inventories/lab.yml](ansible/inventories/lab.yml)

Eine fast identische Konfiguration wurde auch für den Home-Server erstellt:

> [inventories/production.yml](ansible/inventories/production.yml)

Da die Maschine aktuell noch nicht eingerichtet ist, ist die Konfiguration eher hypothetisch.
Für die einzelnen Installationen kann man von Ansible die Ordner- und Filestruktur generieren lassen:

```sh
cd cyber-security-projektarbeit/ansible
ansible-galaxy init roles/docker`
```

Für den eigentlichen Code bin ich einem [Tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-ansible-to-install-and-set-up-docker-on-ubuntu-22-04) von DigitalOcean gefolgt. Zu beginn lief es eigentlich ziemlich gut, jedoch tauchte dann plötzlich eine Fehlermeldung auf:

```sh
TASK [docker : Install Docker CE and required plugins] ************************************************************************************************************************************************************
[ERROR]: Task failed: Module failed: No package matching 'docker-ce' is available
Origin: /home/ddev/automation/cyber-security-projektarbeit/ansible/roles/docker/tasks/install.yml:41:3

39     filename: docker
40
41 - name: Install Docker CE and required plugins
     ^ column 3

fatal: [lab]: FAILED! => {"changed": false, "msg": "No package matching 'docker-ce' is available"}
```

Leider habe ich den Fehler weder mit ChatGPT und Gemini, noch mit altbewährtem Googeln und Stackoverflow nicht gelöst bekommen. Deshalb entschied ich mich für einen Strategiewechsel: Anstatt mit Ansible Scripts von einem Hostcomputer aus ausführen zu lassen, setze ich auf einfache Bash-Dateien. Diese können ganz einfach via `git clone` aus dem Internet gezogen und anschliessend manuell auf dem Home-Server ausgeführt werden.

Dazu habe ich mir folgende Struktur überlegt:

```
cyber-security-projektarbeit/
│
├── scripts/
│   ├── docker/
│   │   └── install.sh
│   │
│   ├── firewall/
│   │   └── install.sh
│   │
│   ├── pihole/
│   │   ├── .env
│   │   ├── .env.template
│   │   ├── docker-compose.yml
│   │   └── install.sh
│   │   
│   ├── wireguard
│   │   ├── .env
│   │   ├── .env.template
│   │   ├── docker-compose.yml
│   │   └── install.sh
│   │   
│   └── install.sh
│
└── README.md/
```

Das `scripts/install.sh` Skript führt nacheinander die `install.sh` Skripts aus den Unterordnern heraus und bricht ab, falls eines der einzelnen Skripts crashen sollte. 

Diese Struktur erlaubt es mir auch, die einzelnen Services separat von einander zu testen oder nur einzelne neu zu deployen. Damit die Docker-Container trotz separiertem `docker-compose.yml` zusammen kommunizieren konnten, musste ich jedoch das interne Netzwerk schon im `docker/install.sh` Skript erstellen und nicht wie sonst üblich im `docker-compose.yml` definieren.

In den `.env` Files habe ich einige Konfigurationen ausgelagert, die je nach Anwender und Anwendungsfall angepasst werden müssen. Damit keine Credentials ins Internet gelangen, habe ich diese Dateien via Gitignore aus dem Repository ausgeschlossen und stattdessen `.env.template`-Files commited, welche zur Erstellung der `.env`-Files kopiert und abgeändert werden können.

### Pi-hole

Um das Pi-hole zu installieren, habe ich mich an die Anleitung unter https://github.com/pi-hole/docker-pi-hole gehalten. Das lief ziemlich reibungslos, ich musste lediglich noch den DNSStubListener von Ubuntu deaktivieren, um den Pi-hole Container an Port 53 verbinden zu lassen.

### VPN

Als VPN installierte ich Wireguard. Bei der Erstellung der `docker-compose` Datei für Wireguard habe ich mich von Gemini unterstützen lassen. Dazu gab ich der KI eine grobe Beschreibung der bisherigen Konfigurationen und die Pi-hole `docker-compose` Datei als Kontext.

Für einen Test habe ich mein Handy (welches mit dem WLAN verbunden war) via Wireguard-App auf meine VM umgeleitet und siehe da - Pi-hole registrierte meinen Traffic: 

![Pi-hole dashboard showing traffic from phone connected via Wireguard](assets/images/pihole-dashboard-wireguard.png)

Wireguard benötigt eine eigene Konfiguration pro Gerät. Aus dem Grund gibt es im `.env` den Wert `WIREGUARD_NUMBER_OF_PEERS`, welcher die gewünschte Anzahl an Peers anlegt. Mit folgendem Befehl lässt sich dann ein QR-Code generieren, welcher mit der Wireguard-App gescannt werden kann, um die Verbindung einzurichten:

```docker exec -it wireguard /app/show-peer 1```

Dabei einfach die 1 mit der Nummer des entsprechenden Peers  ersetzen, damit der QR-Code mit den richtigen Daten generiert werden kann.

### Firewall

Als Firewall habe ich das Paket `ufw` (Uncomplicated Firewall) verwendet. Für die Installation und Konfiguration habe ich mir auch wieder Unterstützung in Form von Gemini geholt. In der Standardkonfiguration umgeht Docker jedoch die Firewall, weshalb ich ein zusätzliches [Paket](https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker) installieren musste, welches das verhindern sollte. Zudem habe ich die Firewall so konfiguriert, dass das Admin-Interface von Pi-hole nur via Wireguard erreichbar sein sollte. 

## Das Resultat

Ich habe Skripte für ein funktionstüchtiges Home-Server Setup erstellt. Da ich mich mit dem Thema nicht so gut auskenne, werde ich aber vor dem "produktiven" Einsatz nochmals alles Skripte und Konfigurationen überprüfen. 

Wenn ich dieses Setup jetzt aufsetzen möchte, müsste ich lediglich mein Ubuntu-Image auf meinem Home-Server installieren, die Skripte laufen lassen und im Router meines LAN den DNS Server auf die IP-Adresse des Home-Servers umstellen. Bisher habe ich aber nur den letzten Teil getesten: das Umleiten des LAN-Traffics über meine VM. Auch das hat gut Funktioniert.

### Erweiterungspläne

Während der Semesterferien plane ich die Erweiterung des Setups um einen Reverse-Proxy, damit ich meine Services und zukünftige Webprojekte via eine leserliche URL erreichen kann.

Ich habe mir überlegt auch noch Fail2Ban einzurichten, jedoch habe ich das für den Moment sein lassen, da Wireguard nur Verbindungen mit Zertifikaten zulässt und es deshalb keine Passwörter gibt, welche Brute-Forced werden könnten um Zugang zum System zu bekommen. Sollte ich aber zukünftig noch andere Ports gegen aussen öffnen wollen als der für Wireguard, so werde ich Fail2Ban noch installieren.