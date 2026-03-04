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

### Ansible

Ansible habe ich via WSL auf meinem Windows-PC installiert. 
Damit Ansible Zugriff auf meine Lab-Umgebung / VM erhält, habe ich folgende Konfiguration erstellt:

#### inventories/lab.yml
```
all:
  hosts:
    debian_vm:
      ansible_host: 192.168.0.49
      ansible_user: vboxuser
      ansible_become: true
      ansible_become_method: sudo
      ansible_python_interpreter: /usr/bin/python3.13
```

Somit kann sich Ansible via SSH mit dem System verbinden und die nötigen Skripts für die Nächsten Schritte.

### Firewall

### Pi-hole

### VPN