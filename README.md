# Wazuh Detection Pack — Proxmox VE

> Règles et décodeurs Wazuh pour **Proxmox VE**, au-delà de l'authentification.
> *Wazuh detection rules & decoders for Proxmox VE — beyond authentication.*

## Le problème

Le support Proxmox VE fourni d'origine avec Wazuh ne décode **que l'authentification** (`pvedaemon`) : 6 décodeurs, 4 règles. Conséquence : une **sauvegarde qui échoue**, une **VM supprimée**, un **accès console**, une **suppression massive de VM** (signature ransomware) — **rien de tout ça ne génère d'alerte**.

Ce pack comble le trou en décodant les **tâches UPID** de Proxmox
(`starting task UPID:…`, `end task UPID:… <statut>`), là où transite l'essentiel de l'activité d'administration.

## Ce que le pack détecte

| Événement Proxmox | Règle | Niveau | MITRE ATT&CK |
|---|---|:---:|---|
| Suppression de VM/CT (`qmdestroy`, `vzdestroy`) | `100210` | 8 | T1485 — Data Destruction |
| **Suppressions multiples corrélées** (ransomware / insider) | `100211` | **12** | T1485 |
| **Échec de sauvegarde** (`vzdump`) | `100220` | 8 | T1490 — Inhibit System Recovery |
| Sauvegarde réussie | `100221` | 3 | — |
| Accès console / shell (`vncshell`, `termproxy`…) | `100230` | 6 | T1021 — Remote Services |

## Prérequis

- Wazuh **4.x** (validé sur **4.14.6**).
- Les décodeurs officiels Proxmox de Wazuh (livrés d'origine — ce pack s'appuie dessus, il ne les remplace pas).
- Les logs Proxmox transmis au manager Wazuh (voir plus bas).

## Installation

```bash
git clone https://github.com/serytia/wazuh-proxmox-detection.git
cd wazuh-proxmox-detection
sudo ./install.sh
```

Le script copie les fichiers, **valide la configuration** (`wazuh-analysisd -t`) puis redémarre Wazuh. Rollback : `sudo ./uninstall.sh`.

### Installation manuelle

Copier `decoders/proxmox-pack_decoders.xml` dans `/var/ossec/etc/decoders/` et
`rules/proxmox-pack_rules.xml` dans `/var/ossec/etc/rules/` (propriétaire `wazuh:wazuh`, mode `660`), puis :

```bash
/var/ossec/bin/wazuh-control restart
```

## Tester sans Proxmox

```bash
while IFS= read -r line; do
  echo "$line" | /var/ossec/bin/wazuh-logtest
done < samples/proxmox-samples.log
```

Vous verrez les décodeurs extraire `pve_task`, `pve_vmid`, `dstuser`, `pve_status`, et les règles se déclencher.

## Envoyer les logs Proxmox à Wazuh

Deux approches :

- **Agent Wazuh sur le nœud Proxmox** — lire `journald` (ou `/var/log/daemon.log`) via un bloc `<localfile>` dans `ossec.conf`.
- **Syslog distant** — configurer Proxmox pour émettre son syslog vers l'IP du manager Wazuh.

## Feuille de route

- Décodeurs `pveum` (création de comptes / **tokens API** — T1136 / T1098) et `pmxcfs` (perte de quorum cluster).
- Dashboard Wazuh prêt à importer.
- Détection du firewall Proxmox.

## Aller plus loin

Ce pack couvre Proxmox. Pour **brancher la détection sur toute votre stack** (pare-feux, Microsoft 365, sauvegardes…), un **déploiement clé en main**, ou une version **white-label pour MSP/MSSP** : ouvrez une **[issue](../../issues)** ou contactez **[@serytia](https://github.com/serytia)**.

## Licence

**GPLv2** — cohérent avec le ruleset Wazuh. Voir [LICENSE](LICENSE).
