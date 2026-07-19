# Dashboard — Proxmox VE detection pack

The pack writes its alerts to the Wazuh index `wazuh-alerts-*`, under the **`proxmox-pack`** group.
Explore them right away in **Wazuh Dashboard → Threat Hunting / Discover**, or build a dashboard
from a few visualizations.

## Ready-made searches (DQL)

| Goal | Query |
|---|---|
| All pack alerts | `rule.groups: "proxmox-pack"` |
| VM/CT deletions (T1485) | `rule.groups: "pve_destroy"` |
| **Ransomware signature** (multiple deletions) | `rule.id: "100211"` |
| Failed backups (T1490) | `rule.groups: "pve_backup_failed"` |
| Deleted snapshots (T1490) | `rule.groups: "pve_snapshot_delete"` |
| Interactive console access | `rule.id: "100230"` |
| Cluster / quorum | `rule.groups: "pve_cluster"` |
| **Quorum loss** | `rule.id: "100241"` |

Decoded fields you can use: `data.pve_task`, `data.pve_vmid`, `data.pve_status`,
`data.pve_subsystem`, `data.pve_level`, `data.pve_msg`, `data.dstuser`, `rule.mitre.id`.

## Recommended visualizations

| Panel | Type | Query / field |
|---|---|---|
| Pack alerts over time | Line (date histogram) | `rule.groups: "proxmox-pack"` |
| MITRE ATT&CK breakdown | Pie | field `rule.mitre.id` |
| Deletions by user | Bars | `rule.groups: "pve_destroy"` · field `data.dstuser` |
| Backups OK vs failed | Bars | filter `data.pve_task: vzdump` · field `data.pve_status` |
| Quorum health | Table | `rule.groups: "pve_cluster"` |
| Alert log | Saved search | columns `rule.level`, `rule.description`, `data.pve_task`, `data.pve_vmid`, `data.dstuser`, `agent.name` |

## One-click import

The **"Proxmox VE - Detection (pack)"** dashboard ships ready to import:
[`pve-dashboard.ndjson`](pve-dashboard.ndjson) — counter, MITRE ATT&CK pie, timeline by severity
level, top users ("who acts"), and an alert table. **Validated on Wazuh Dashboard 4.14 /
OpenSearch Dashboards 2.19.**

- **Via the UI**: *Dashboards Management → Saved Objects → Import* → `pve-dashboard.ndjson` →
  *Import* (check "overwrite"). Then open "Proxmox VE - Detection (pack)" and set the time picker
  to *Last 24 hours*.
- **Via the API**:
  ```bash
  curl -sk -u admin:PASS -H "osd-xsrf: true" \
    -F file=@pve-dashboard.ndjson \
    "https://YOUR-DASHBOARD/api/saved_objects/_import?overwrite=true"
  ```

It references the `wazuh-alerts-*` index pattern (Wazuh's default ID). If your install uses a
different ID, adjust the reference in the `.ndjson`.
