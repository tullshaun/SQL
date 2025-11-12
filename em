Subject: Clarification: Security Finding – DWRCS.exe (Not Part of SolarWinds Orion Platform)

Body:

Hello [Security Team / All],

Thank you for flagging the presence of DWRCS.exe on several servers.
After review, we’d like to clarify that this executable belongs to Dameware Mini Remote Control, a stand-alone remote support tool once acquired by SolarWinds, but it is not part of the SolarWinds Orion Platform or any component managed by our team.

Our team’s scope covers the SolarWinds Orion environment (SAM, NPM, etc.), which remains fully current, patched, and actively maintained.
We have never deployed or administered Dameware, and it operates independently of Orion.

To avoid confusion in future audits or reports, we recommend categorising any DWRCS.exe findings under legacy third-party remote support software, not under SolarWinds Orion.
We’re happy to assist in confirming system ownership or providing version details from the Orion side if needed.

Kind regards,
[Your Name]
[Your Role / Team Name]
