# Wazuh Detection Pack — Proxmox VE

> Wazuh rules & decoders for **Proxmox VE** — beyond authentication.

## The problem

Wazuh's out-of-the-box Proxmox VE support decodes **only authentication** (`pvedaemon`): a **failed backup**, a **deleted VM/CT**, **console access**, a **mass deletion** (ransomware signature), a cluster **quorum loss** — none of it raises an alert.

This pack fills the gap by decoding Proxmox **UPID tasks** and **pmxcfs** (cluster) messages. A key point verified on a real Proxmox VE 9.2: tasks are logged under **different** `program_name` values depending on origin — `pvedaemon` (web UI/API), but `pct`/`qm` (CLI) and `vzdump`/`pvescheduler` (**backups, including scheduled ones**). The pack covers **both paths**, so backups and command-line actions don't slip through.

> **Making-of** — building the lab (Proxmox VE + Wazuh), the pitfalls, and the `program_name` flaw caught during real testing: [full write-up on rhnetwork.xyz](https://rhnetwork.xyz/blog/proxmox-wazuh-angle-mort/) *(in French)*.

## What the pack detects

| Proxmox event | Rule | Level | MITRE ATT&CK |
|---|---|:---:|---|
| VM/CT deletion (`qmdestroy`, `vzdestroy`) | `100210` | 8 | T1485 — Data Destruction |
| **Correlated multiple deletions** (ransomware / insider) | `100211` | **12** | T1485 |
| Snapshot deletion (`qmdelsnapshot`, `vzdelsnapshot`) | `100213` | 6 | T1490 — Inhibit System Recovery |
| **Backup failure** (`vzdump`) | `100220` | 8 | T1490 |
| Backup success | `100221` | 3 | — |
| Restore (`qmrestore`, `vzrestore`) | `100212` | 6 | — |
| Migration (`qmigrate`, `vzmigrate`) | `100214` | 4 | — |
| Console / shell access (`vncshell`, `termproxy`…) | `100230` | 6 | T1021 — Remote Services |
| Cluster **quorum loss** (`pmxcfs`) | `100241` | 10 | — |
| Cluster critical error (`pmxcfs`) | `100242` | 8 | — |
| Quorum restored | `100243` | 3 | — |

Covers tasks launched via the **UI/API** *and* via the **CLI/`vzdump`** (scheduled backups included).

## Requirements

- Wazuh **4.x** (validated on **4.14.6**).
- Wazuh's official Proxmox decoders (shipped by default — the pack builds on `pvedaemon` for the UI path, it does not replace them).
- Proxmox logs forwarded to the Wazuh manager (see below). Validated on a real **Proxmox VE 9.2**.

## Installation

```bash
git clone https://github.com/serytia/wazuh-proxmox-detection.git
cd wazuh-proxmox-detection
sudo ./install.sh
```

The script copies the files, **validates the configuration** (`wazuh-analysisd -t`), then restarts Wazuh. Rollback: `sudo ./uninstall.sh`.

### Manual installation

Copy `decoders/proxmox-pack_decoders.xml` to `/var/ossec/etc/decoders/` and
`rules/proxmox-pack_rules.xml` to `/var/ossec/etc/rules/` (owner `wazuh:wazuh`, mode `660`), then `/var/ossec/bin/wazuh-control restart`.

## Test without Proxmox

```bash
while IFS= read -r line; do
  echo "$line" | /var/ossec/bin/wazuh-logtest
done < samples/proxmox-samples.log
```

The samples cover both paths (UI `pvedaemon` and CLI `pct`/`vzdump`) and the cluster.

## Send Proxmox logs to Wazuh

- **Wazuh agent on the Proxmox node** — read `journald` via a `<localfile>` block (`log_format journald`) in `ossec.conf`.
- **Remote syslog** — configure Proxmox to emit its syslog to the Wazuh manager.

## Dashboard

Ready-to-use queries and visualizations in [`dashboard/README.md`](dashboard/README.md).

## Roadmap

- `pveum` decoders (account / API token creation) — **to confirm**: these actions are not logged to standard syslog on Proxmox VE (they live in the `pveproxy` access logs).
- Proxmox firewall detection (`pve-firewall`).

## Going further

This pack covers Proxmox. To **wire detection across your whole stack** (firewalls, Microsoft 365, backups…), a **turnkey deployment**, or a **white-label build for MSP/MSSP**: open an **[issue](../../issues)** or reach out to **[@serytia](https://github.com/serytia)**.

## License

**GPLv2** — consistent with the Wazuh ruleset. See [LICENSE](LICENSE).
