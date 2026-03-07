# Projektarbeit Cyber Security

Projektarbeit im Rahmen des Fachs "Cyber Security" im "Informatiker HF"-Lehrgang an der Teko.

## Inhalt
- [Der Plan](#der-plan)
- [Die Ausführung](#die-ausführung)
    - [Firewall](#firewall)
    - [Pi-hole](#pi-hole)
    - [VPN](#vpn)


## Der Plan

Ich habe schon länger mit dem Gedanken gespielt, meinen alten PC zu einem Home-Server umzubauen, mir hat aber der Anstoss gefehlt, da kommt mir diese Projektarbeit sehr gelegen.

Geplant ist die Installation und Konfiguration folgender Dienste: 

- **Pi-hole:** Zur Blockierung von Werbung in meinem Heimnetzwerk.
- **VPNs:** Zur Verbesserung der Sicherheit, falls ich mal auf öffentliche Hotspots angewiesen sein sollte und auch auf meinen mobilen Geräten vom Pi-hole profitieren kann.
- **Firewall:** Zur Verbesserung der Sicherheit meines Heimnetzwerks.

**Infrastructure as Code:** Zusätzlich habe ich für mich die Anforderung, dass ich diese Dienste automatisiert installieren und konfigurieren können will. Sprich das Hauptprodukt dieser Arbeit werden die Skripts sein, mit denen sich diese Dienste installieren lassen können.

Da ich über keinerlei Erfahrungen mit dem Einrichten dieser Dienste und dem Konzept von Infrastructure as Code habe, habe ich mir zur groben Planung des Projekts ChatGPT zu Hilfe gezogen. 


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



## Die Ausführung

### Lab-Environment 

Um die Ansible-Skripte zu testen, habe ich mit VirtualBox eine Ubuntu 24.04.4 LTS  VM erstellt und diese mit einem Bridge-Adapter in meinem LAN verfügbar gemacht. Damit kann ich meinen alten PC simulieren, auf dem die Services dann laufen werden.

Hier musste ich als erstes SSH installieren und dem `vboxuser` erlabuen, Befehle mit `sudo` auszuführen.

### Ansible

Ansible habe ich via WSL auf meinem Windows-PC installiert. 
Damit Ansible Zugriff auf das Lab-Environment erhält und die Skripts ausführen kann, habe ich folgende Konfiguration erstellt:

> [inventories/lab.yml](ansible/inventories/lab.yml)

Eine fast identische Konfiguration wird auch für den Home-Server erstellt:

> [inventories/production.yml](ansible/inventories/production.yml)

Da die Maschine aktuell noch nicht eingerichtet ist, sind hier vorerst nur Platzhalter eingefügt.

Anschliessend habe ich von Ansible die Ordner- und Filestruktur generieren lassen:

```sh
cd cyber-security-projektarbeit/ansible
ansible-galaxy init roles/docker`
```

Für die Erstellung des Docker-Skripts bin ich einem [Tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-ansible-to-install-and-set-up-docker-on-ubuntu-22-04) von DigitalOcean gefolgt.

Ansible-Skripte ausführen (für Testdurchläufe kann `--check` angefügt werden): 
``` sh
ansible-playbook -i inventories/lab.yml lab-playbook.yml -K
```


### Firewall



### Pi-hole

### VPN