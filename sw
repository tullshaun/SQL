SolarWinds Disaster Recovery Overview
Promotion of DR Polling Infrastructure to Primary Role
Executive Summary
In the event of a failure at the Primary Data Centre, SolarWinds monitoring services are swiftly restored by promoting an existing Disaster Recovery (DR) polling engine to act as the Primary Monitoring Engine. This enables monitoring, alerting, and reporting services to resume, utilising the existing SolarWinds database infrastructure hosted in the DR environment. This approach takes advantage of currently licensed polling infrastructure and ensures continuity of service without the need for additional permanent servers.
Current Architecture Overview
•	SolarWinds platform is deployed across two data centres: Primary and DR.
•	The SolarWinds database is protected using SQL Always On, ensuring data availability in DR.
•	Two active SolarWinds polling engines operate in the DR data centre, continuously monitoring DR-based systems.
•	The Primary Monitoring Engine normally operates in the Primary Data Centre.
DR Strategy Overview
When the Primary Data Centre is unavailable:
1.	One existing DR polling engine is promoted to the Primary Monitoring role.
2.	The other DR polling engine continues operating as a supporting poller.
3.	The SolarWinds database remains available via SQL Always On.
4.	Monitoring, alerting, and reporting services are restored from DR.
5.	This process restores full SolarWinds platform functionality within the DR environment.
What “Promotion” Means in Practice
•	Enabling primary monitoring and orchestration services on an existing polling server.
•	Assigning responsibility for alerting, reporting, and job coordination.
•	Re-establishing the SolarWinds user interface and management services.
•	Re-integrating remaining polling engines under central coordination.
•	No monitoring data is lost, and existing configurations, alerts, and historical information remain intact.
Why This Approach Is Used
•	Avoids maintaining idle standby infrastructure.
•	Uses existing licensed polling capacity.
•	Minimises DR cost while maintaining recoverability.
•	Aligns with SolarWinds supported recovery models.
Recovery Characteristics
Area	Outcome
Monitoring data	Preserved
Alerts & reports	Restored
DR polling capacity	Maintained
Manual intervention	Required
Recovery time	Dependent on promotion activity
Risks and Controls
•	Risk: Temporary reduction in polling capacity during promotion
•	Control: Selection of the least-loaded polling engine
•	Risk: Manual recovery steps
•	Control: Documented and tested recovery procedure
Future Enhancements (Optional)
If faster or automated recovery is required, options include:
•	Introducing High Availability for the Primary Monitoring Engine.
•	Pre-staging a standby Primary Engine in DR.
•	Automating service activation and DNS redirection.

