# Wazuh Detection Pack — Proxmox VE

> Règles et décodeurs Wazuh pour **Proxmox VE**, au-delà de l'authentification.
> *Wazuh detection rules & decoders for Proxmox VE — beyond authentication.*

## Le problème

Le support Proxmox VE fourni d'origine avec Wazuh ne décode **que l'authentification** (`pvedaemon`) : une **sauvegarde qui échoue**, une **VM/CT supprimé**, un **accès console**, une **suppression massive** (signature ransomware), une **perte de quorum** cluster — rien de tout ça ne génère d'alerte.

Ce pack comble le trou en décodant les **tâches UPID** de Proxmox et les messages **pmxcfs** (cluster). Point crucial vérifié sur un Proxmox VE 9.2 réel : les tâches sont journalisées sous des `program_name` **différents** selon l'origine — `pvedaemon` (UI/API web), mais `pct`/`qm` (CLI) et `vzdump`/`pvescheduler` (**sauvegardes, y compris planifiées**). Le pack couvre **les deux voies**, donc les backups et les actions en ligne de commande ne passent pas au travers.

## Ce que le pack détecte

| Événement Proxmox | Règle | Niveau | MITRE ATT&CK |
|---|---|:---:|---|
| Suppression de VM/CT (`qmdestroy`, `vzdestroy`) | `100210` | 8 | T1485 — Data Destruction |
| **Suppressions multiples corrélées** (ransomware / insider) | `100211` | **12** | T1485 |
| Suppression de snapshot (`qmdelsnapshot`, `vzdelsnapshot`) | `100213` | 6 | T1490 — Inhibit System Recovery |
| **Échec de sauvegarde** (`vzdump`) | `100220` | 8 | T1490 |
| Sauvegarde réussie | `100221` | 3 | — |
| Restauration (`qmrestore`, `vzrestore`) | `100212` | 6 | — |
| Migration (`qmigrate`, `vzmigrate`) | `100214` | 4 | — |
| Accès console / shell (`vncshell`, `termproxy`…) | `100230` | 6 | T1021 — Remote Services |
| **Perte de quorum** cluster (`pmxcfs`) | `100241` | 10 | — |
| Erreur critique cluster (`pmxcfs`) | `100242` | 8 | — |
| Rétablissement du quorum | `100243` | 3 | — |

Couvre les tâches lancées via l'**UI/API** *et* via la **CLI/`vzdump`** (backups planifiés inclus).

## Prérequis

- Wazuh **4.x** (validé sur **4.14.6**).
- Les décodeurs officiels Proxmox de Wazuh (livrés d'origine — le pack s'appuie sur `pvedaemon` pour la voie UI, il ne les remplace pas).
- Les logs Proxmox transmis au manager Wazuh (voir plus bas). Validé sur **Proxmox VE 9.2** réel.

## Installation

```bash
git clone https://github.com/serytia/wazuh-proxmox-detection.git
cd wazuh-proxmox-detection
sudo ./install.sh
```

Le script copie les fichiers, **valide la configuration** (`wazuh-analysisd -t`) puis redémarre Wazuh. Rollback : `sudo ./uninstall.sh`.

### Installation manuelle

Copier `decoders/proxmox-pack_decoders.xml` dans `/var/ossec/etc/decoders/` et
`rules/proxmox-pack_rules.xml` dans `/var/ossec/etc/rules/` (propriétaire `wazuh:wazuh`, mode `660`), puis `/var/ossec/bin/wazuh-control restart`.

## Tester sans Proxmox

```bash
while IFS= read -r line; do
  echo "$line" | /var/ossec/bin/wazuh-logtest
done < samples/proxmox-samples.log
```

Les samples couvrent les deux voies (UI `pvedaemon` et CLI `pct`/`vzdump`) et le cluster.

## Envoyer les logs Proxmox à Wazuh

- **Agent Wazuh sur le nœud Proxmox** — lire `journald` via un bloc `<localfile>` (`log_format journald`) dans `ossec.conf`.
- **Syslog distant** — configurer Proxmox pour émettre son syslog vers le manager Wazuh.

## Tableau de bord

Requêtes et visualisations prêtes à l'emploi dans [`dashboard/README.md`](dashboard/README.md).

## Feuille de route

- Décodeurs `pveum` (création de comptes / tokens API) — **à valider** : ces actions ne sont pas journalisées en syslog standard sur Proxmox VE (elles vivent dans les access logs `pveproxy`).
- Détection du firewall Proxmox (`pve-firewall`).
- Fichier `.ndjson` de dashboard importable.

## Aller plus loin

Ce pack couvre Proxmox. Pour **brancher la détection sur toute votre stack** (pare-feux, Microsoft 365, sauvegardes…), un **déploiement clé en main**, ou une version **white-label pour MSP/MSSP** : ouvrez une **[issue](../../issues)** ou contactez **[@serytia](https://github.com/serytia)**.

## Licence

**GPLv2** — cohérent avec le ruleset Wazuh. Voir [LICENSE](LICENSE).
