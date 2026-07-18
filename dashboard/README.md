# Dashboard — Proxmox VE detection pack

Le pack écrit ses alertes dans l'index Wazuh `wazuh-alerts-*`, sous le groupe **`proxmox-pack`**.
Explore-les tout de suite dans **Wazuh Dashboard → Threat Hunting / Discover**, ou monte un
tableau de bord en quelques visualisations.

## Recherches prêtes (DQL)

| Objectif | Requête |
|---|---|
| Toutes les alertes du pack | `rule.groups: "proxmox-pack"` |
| Suppressions de VM/CT (T1485) | `rule.groups: "pve_destroy"` |
| **Signature ransomware** (suppressions multiples) | `rule.id: "100211"` |
| Sauvegardes en échec (T1490) | `rule.groups: "pve_backup_failed"` |
| Snapshots supprimés (T1490) | `rule.groups: "pve_snapshot_delete"` |
| Accès console interactif | `rule.id: "100230"` |
| Cluster / quorum | `rule.groups: "pve_cluster"` |
| **Perte de quorum** | `rule.id: "100241"` |

Champs décodés exploitables : `data.pve_task`, `data.pve_vmid`, `data.pve_status`,
`data.pve_subsystem`, `data.pve_level`, `data.pve_msg`, `data.dstuser`, `rule.mitre.id`.

## Visualisations recommandées

| Panneau | Type | Requête / champ |
|---|---|---|
| Alertes du pack dans le temps | Ligne (date histogram) | `rule.groups: "proxmox-pack"` |
| Répartition MITRE ATT&CK | Camembert | champ `rule.mitre.id` |
| Suppressions par utilisateur | Barres | `rule.groups: "pve_destroy"` · champ `data.dstuser` |
| Sauvegardes OK vs échec | Barres | filtre `data.pve_task: vzdump` · champ `data.pve_status` |
| Santé du quorum | Table | `rule.groups: "pve_cluster"` |
| Journal des alertes | Saved search | colonnes `rule.level`, `rule.description`, `data.pve_task`, `data.pve_vmid`, `data.dstuser`, `agent.name` |

## Import « 1-clic » (à venir)

Un fichier `.ndjson` importable (*Stack Management → Saved Objects → Import*) sera fourni une
fois **validé sur un vrai Wazuh Dashboard** : l'ID de l'index-pattern `wazuh-alerts-*` diffère
d'une installation à l'autre, il doit être calé sur l'instance cible sous peine d'import cassé.
Le mien n'exécute que le *manager* (assez pour tester la détection, pas pour valider un dashboard).
