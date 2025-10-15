x
Subject: URGENT ESCALATION: Critical SolarWinds-Microsoft Defender Compatibility Defect - Case [Number]

Dear SolarWinds Support,

We are writing to formally escalate Case [Number] due to the unacceptable diagnostic approach and lack of progress in resolving a critical compatibility issue between the Orion Platform and Microsoft Defender.

1. Rejection of Current Diagnosis
Your analysis incorrectly identifies the symptoms as the root cause. The repeated crashing of the "Microsoft Defender Antivirus Network Inspection Service" is not merely a side effect of resource utilization—it is the core compatibility defect. For a core Windows security service to crash repeatedly indicates a fundamental conflict at the system level, not a configuration issue.

Your hypothesis that high polling causes these crashes is contradicted by our controlled evidence: the identical SolarWinds configuration operated without issue under Trend Micro antivirus. The only variable is the antivirus solution, confirming the conflict is specifically between SolarWinds and Microsoft Defender.

2. Unaddressed Critical Requirements
For one week, we have repeatedly requested a vendor-validated exclusion list for Microsoft Defender. The generic KB article recommending blanket directory exclusions is security-wise unacceptable for our regulated banking environment and does not resolve the underlying compatibility issue.

3. Required Immediate Actions
Given the criticality of this stability and security issue, we require the following within 24 hours:

Immediate escalation to your Senior Engineering or Security Response team capable of addressing software compatibility defects

Provision of a specific, minimal exclusion list for Microsoft Defender that has been validated by your product engineering team

Confirmation of whether SolarWinds has any known compatibility advisories regarding Microsoft Defender

Assignment of a Technical Account Manager to provide direct communication for this escalation

If we do not receive confirmation of these actions and a substantive technical response within 24 hours, we will escalate this through our vendor management executive channels and file a formal product defect notice.

As a global corporate bank, we cannot accept unstable security services or broad security exceptions. We require SolarWinds to take ownership of this compatibility issue and provide an enterprise-grade solution.

Sincerely,

[Your Name]
[Your Title/Department]
[Bank Name]



Subject: URGENT ESCALATION — Microsoft Defender Compatibility Issue Causing Service Crashes (Case #[Number])

Dear SolarWinds Support,

It has now been one week since this issue was raised, and the responses received do not address the core technical or compliance concerns. The situation remains unresolved and requires immediate escalation to Tier-3 Engineering.

1. Core Issue

The repeated termination of the “Microsoft Defender Antivirus Network Inspection Service” is the central problem — not a side effect.
This behavior indicates a compatibility or resource-locking conflict between the SolarWinds Orion Platform and Microsoft Defender, impacting a core Windows security service.
In a regulated banking environment, any software that destabilizes a native security control constitutes a critical risk requiring immediate vendor investigation.

2. Why the Current Explanation Is Invalid

Correlation ≠ Causation
Higher polling activity may increase CPU load, but it does not repeatedly crash a protected Windows service.
The consistent Defender NIS failures point to a deep compatibility issue, not simple configuration or tuning.

Controlled Comparison Confirms the Root Cause
The same SolarWinds configuration operated flawlessly under Trend Micro antivirus.
The only variable change was the AV engine, isolating the conflict to SolarWinds ↔ Defender interaction.

Unaddressed Customer Request
We have repeatedly requested a formal, vendor-endorsed Defender exclusion list, validated by your engineering team.
A blanket exclusion of C:\Program Files (x86)\SolarWinds\ is not acceptable under our internal audit controls.
We require a granular, tested, and security-reviewed exclusion set specific to Orion Platform 2024.x.

3. Required Immediate Actions

Please action the following without further delay:

Escalate this ticket to your Senior Engineering or Security Response team for formal analysis.

Provide a tested, vendor-approved exclusion list for Microsoft Defender that applies to Orion Platform 2024.x and its modules (SAM, NPM, UDT, IPAM, etc.).

Confirm any known compatibility advisories or KBs jointly published by SolarWinds or Microsoft on this topic.

Assign a named escalation contact (Technical Account Manager or Engineering Lead).

If no traction is achieved within 24–48 hours, we will escalate through vendor-management and compliance channels and classify this as a critical product defect.

4. Additional Context

This environment is part of a corporate banking network subject to internal and external audit.

A third-party application repeatedly crashing a core Windows Defender service is a material compliance concern.

Our internal Security and Microsoft Premier Support teams are now jointly monitoring this case.

We expect a formal engineering-level response with documented exclusions, compatibility confirmation, and a remediation plan.

Kind regards,
[Your Full Name]
[Your Job Title / Department]
[Bank Name]
[Case Reference / Ticket #]





Dear SolarWinds Support,

It has now been one week since this issue was raised, and the responses received do not address the core technical or compliance concerns. The situation remains unresolved and requires immediate escalation.

Core Issue

The repeated termination of the “Microsoft Defender Antivirus Network Inspection Service” is the problem — not a side effect.
This indicates a compatibility or resource-locking conflict between the SolarWinds Orion Platform and Microsoft Defender, affecting a core Windows security service. This is a critical stability and security issue that must be reviewed by your engineering or security response team.

Why the Current Explanation Is Invalid

Correlation ≠ Causation
High polling activity can increase CPU usage but cannot repeatedly crash a protected Windows service. The consistent Defender service failures indicate a deep compatibility conflict, not a configuration or tuning issue.

Controlled Comparison Already Conducted
The exact same SolarWinds configuration operated without issue under Trend Micro antivirus. The only variable changed was the antivirus engine. Therefore, the fault domain is clearly between SolarWinds and Microsoft Defender.

Unaddressed Customer Request
We have repeatedly asked for a formal, vendor-endorsed exclusion list for Microsoft Defender — not a generic KB reference.
A blanket exclusion of C:\Program Files (x86)\SolarWinds\ is not acceptable in a regulated banking environment. We require a minimal, validated exclusion set supported by your product engineering team.

Required Next Steps

To proceed, please:

Escalate this ticket immediately to your Senior Engineering or Security Response team for formal analysis.

Provide a tested and vendor-approved exclusion list for Microsoft Defender that applies to Orion Platform 2024.x and related modules.

Confirm whether SolarWinds has any known compatibility advisories or KBs with Microsoft Defender.

Provide a named escalation or technical account manager contact.

If no traction is achieved within 24–48 hours, this case will be escalated through our vendor management and compliance channels as a critical product defect.

Additional Notes for Context

The environment in question is a corporate banking network subject to internal audit.

A third-party product causing repeated Windows Defender service crashes is a material compliance risk.

Our internal security and Microsoft support teams are aware and tracking this issue under cross-vendor review.

We request a formal engineering-level response with documented exclusions and compatibility confirmation as soon as possible.

Kind regards,
[Your Name]
[Your Title / Department]
[Bank Name]
[Case Reference]


Subject: URGENT ESCALATION REQUIRED - Re: Case [Number] - MS Defender Service Crashing

Thank you for the update. However, your analysis does not address the core issue and we must insist on an escalation.

The Defender Service Crashes Are the Problem, Not a Symptom. The repeated, consistent crashing of the "Microsoft Defender Antivirus Network Inspection Service" indicates a fundamental compatibility issue between the SolarWinds software and a core Windows security component. This is a critical stability and security concern that must be investigated by your engineering team.

Your Resource-Based Hypothesis is Contradicted by the Evidence. We ran the exact same SolarWinds configuration and polling load with Trend Micro antivirus for an extended period with zero issues. The only variable that changed was the antivirus solution. Therefore, the conflict is specifically between SolarWinds and Microsoft Defender, not our polling configuration.

You Have Not Addressed Our Repeated Request. We have asked multiple times for the specific, minimum-required exclusion list for Microsoft Defender that your product engineering team has validated. We cannot and will not use the broad, insecure exclusion of the entire SolarWinds directory as suggested in your public KB. This is a requirement for our security compliance.

We require the following immediate actions:

Immediately escalate this case to your Senior Engineering Team or Security Response Team. This is beyond the scope of a standard support ticket regarding performance tuning.

Provide a direct line of communication to a Technical Account Manager or Escalation Manager.

Your team must provide the specific file, process, and network exclusions required for stable operation with Microsoft Defender.

If we cannot get traction on this path within 24-48 hours, we will be forced to escalate through our vendor management channels and consider this a critical product defect.

Subject: URGENT: Unacceptable Diagnosis and Action Plan for High CPU Conflict with MS Defender (Ticket # [Insert Ticket Number])

Dear SolarWinds Support Team,

Thank you for your latest analysis regarding the critical performance issue affecting our environment: 100% CPU utilization on our pollers when running the Orion Platform alongside Microsoft Defender.

We find the conclusions in your last communication to be unacceptable and a misdiagnosis of the root problem.

1. Rejection of the Diagnosis and Redirection
Your analysis, citing the Defender Network Inspection Service termination and high CPU from the JobEngine Worker (121%) and Collector Service (48%), actually confirms our position: SolarWinds processes are the primary resource consumers and the source of the contention.

The termination of the Microsoft Defender service is a symptom of severe resource starvation caused by your software, not the root cause.

While we will review the node distribution to optimize overall performance (addressing your 411% internal load metric), this is a separate optimization task that does not address the core compatibility flaw.

The critical issue remains: Your software operated normally with Trend Micro, but causes a crash-level resource conflict with Microsoft Defender. This is a fundamental compatibility failure that requires a security fix, not merely a configuration change.

2. Demand for Immediate, Specific, and Security-Compliant Action
Given our status as a global corporate bank, we cannot and will not accept solutions that increase our security risk. We require the following actions, which we expect from a critical enterprise vendor:

Requirement	Justification
Official, Granular Exclusion List	You have repeatedly failed to provide the necessary list. We require a precise, security-reviewed list of specific files and processes that must be excluded. We will not implement blanket directory exclusions (e.g., C:\Program Files (x86)\SolarWinds\) as this creates an unacceptable security blind spot.
Engineering Engagement	We demand that your engineering team work with the data provided to replicate this conflict in your own lab environment with Microsoft Defender enabled. This will confirm the process-level interaction that is causing the resource loop.
Hotfix or Patch Commitment	We require a definitive timeline for a hotfix or patch that corrects the excessive resource consumption when Defender is actively scanning/inspecting your binaries. This is a compatibility defect, not an environmental configuration issue.

Export to Sheets
Please escalate this ticket immediately to a Tier 3 Engineering resource capable of providing the technical solution and security assurances required for an enterprise deployment.

We need a concrete, actionable plan to resolve the Defender conflict within 24 hours.



