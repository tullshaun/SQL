Subject: RCA: Stale Monitoring Data Following gMSA Password Rotation (SZ Poller)

Hi Team,

I wanted to provide a full summary and root cause analysis of the recent issue where multiple servers appeared “up” but were no longer returning detailed monitoring statistics.

🔍 Issue Summary

Following a scheduled gMSA password rotation in the SZ domain, approximately 80% of nodes stopped returning detailed statistics (WMI/WinRM/SAM), while ICMP polling continued to report them as Up (green).

~80% of nodes → ❌ stale / no stat data
~20% of nodes → ✅ continued working normally
ICMP (ping) → ✅ remained green for all nodes

This created a false-green condition, where systems appeared healthy but were not being properly monitored.

The issue was isolated to the SZ poller in the SZ domain, which uses gMSA credentials.
The main poller (primary domain) was unaffected and does not use gMSA.

📄 Findings
SolarWinds logs showed “access denied” errors for affected nodes
Connectivity was confirmed (ICMP working)
Switching the polling credential to another account restored data collection
Switching back to the gMSA account also worked again
🎯 Root Cause

The issue was triggered by gMSA password rotation, but the underlying cause was:

Stale cached authentication context (Kerberos/session) on the SZ poller

After the password rotation:

SolarWinds continued using existing Kerberos tickets / cached auth sessions
These became invalid after rotation
Result: access denied for WMI/WinRM polling
ICMP unaffected (no authentication required)

Rebinding the credential forced a refresh of authentication context, resolving the issue.

⚠️ Key Insight

ICMP = reachability only, NOT monitoring health

This incident exposed a monitoring blind spot, where systems can appear healthy but are not being properly observed.

🔧 Available Fixes

1. Restart SolarWinds polling services (Recommended)

SolarWinds Information Service
SolarWinds Job Engine
SolarWinds Collector Service

✔ Clears cached sessions
✔ Forces new authentication context

2. Rebind credentials (current workaround)

Change polling account → apply
Change back to gMSA

✔ Forces authentication refresh

3. Purge Kerberos tickets (on poller)

klist purge

✔ Forces new ticket acquisition
⚠ May still require service restart

4. Restart WMI / WinRM (target servers, if needed)
✔ Only if provider issues suspected

5. Full poller restart
✔ Guarantees clean state
⚠ Higher operational impact

🚀 Recommended Operational Approach

After future gMSA rotations:

Restart SolarWinds polling services on the SZ poller

This is the simplest and most reliable method.

🛡️ Preventative Improvements

1. Detect “false green” conditions

Alert when:
Node = Up (ICMP)
BUT stats are stale (no recent poll)

2. Dashboard visibility

Highlight nodes with:
ICMP Up
No stat updates

3. Monitor polling failures

Track access denied / auth failures
❓ Open Question / Improvement Area

Is there a way to detect when the gMSA password has changed or is about to change, so we can:

Proactively restart polling services
Or trigger automated validation

Possible approaches to explore:

Active Directory/KDS event logs
Scheduled checks on gMSA password metadata
Monitoring Kerberos ticket refresh behaviour

If anyone has experience or recommendations in this area, it would be useful to standardise a proactive approach.

🧾 Summary

The issue was caused by stale authentication context on the SZ poller following gMSA password rotation, leading to access denied errors for detailed polling. ICMP continued to report nodes as up, masking the issue. Restarting or rebinding credentials refreshed authentication and restored monitoring.

Please let me know if we w
