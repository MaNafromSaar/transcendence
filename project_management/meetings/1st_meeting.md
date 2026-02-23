### 1st meeting "transcendence"

 0. Organizational notes
 1. Project overview & vision
 2. Timeframe & milestones
 3. Team roles & responsibilities
 4. Documentation structure
 5. Sprint planning & task breakdown
 6. Next steps & action items

## 0. Organizational Notes
- Calendar tool? (project management software --> research which has included tools like that - check Notion, GitHub Projects, Trello, etc. also proton.me)
- Communication channel --> Discord
- Meeting cadence - 2x a week. One on Tuesday for 30 min to check progress and adjust if needed, and one on Friday for 1h to review the week and plan next steps.
18h
- One platform? like Notion or GitHub Wiki for documentation? Or just markdown files in the repo?
- extra mail for project-related communication? (or just use personal emails and cc the PM?) Thinking of proton.me
- ultimate deadline? --> Lewin Blackhole 85+ days GOOD NEWS!

## 1. Project Overview & Vision
- Build a local ERP system with AI capabilities using Docker Compose.
- Leverage open-source tools: PostgreSQL, n8n, Ollama, Metabase, pgAdmin, and custom FastAPI wrappers.
- Focus on small businesses and freelancers needing a self-hosted solution with AI-powered features.
- remarks about current state of the project, what has been done, and what is left to do.
- gathering ideas for ERP features

Feedback on the project:
- Silvestri already does N8N!!! Workflow creator and tester found
- Daniel: Building up knowledge base
- _Sales Slogan: "Empower your business with AI-driven insights and automation — all on your local hardware!" What others pay thousands a year for, you can run on your own machine with our self-hosted ERP solution._

- Daniel: Compliance Master


- Taulant is not available it seems. Fill up the ranks? --> Only if a really fitting candidate is found that can contribute meaningfully. With 4 members, we can still cover all roles by combining some (e.g., PM + PO, Tech Lead + Dev). Adding a 5th would allow for more specialization but is not strictly necessary.



## 2. Timeframe & Milestones
- Project duration: February 2026 – April 2026 (3 months)
	 
- Key milestones:
  - Sprint 0 (Feb 21): Project setup, documentation, and local validation (already done)
  - Sprint 1 (Feb 22 – Mar 14): Core stack testing, developing ideas for ERP features, and defining architecture, research
  - Sprint 2 (Mar 15 – Mar 28): ERP foundation and RAG pipeline
  - Sprint 3 (Mar 29 – Apr 11): AI features and UX improvements
- Final review and presentation: April 15, 2026

## 3. Team Roles & Responsibilities
- Project Manager (PM): Matthias Naumann — oversees project execution, timelines, and team coordination
- Technical Lead / Architect: Lewin Sorg — responsible for technical decisions, architecture, and code quality
- Product Owner / Compliance Officer: Daniel Springer — defines product requirements, ensures compliance, and validates features
- Developer and Design: Silvestri — implement features, test, and provide UX feedback


## 4. Documentation Structure
- already up to subject requirements, any other suggestions/wishes? - stay with github and md files for as long as possible, leverage all tools of that platform


## 5. Sprint Planning & Task Breakdown
- Your realistic aims towards next Friday, Meeting in between on Tuesday to check progress and adjust if needed.

- Matthias: 
	- set up a fake user company, with some contacts, invoices, projects, and a few documents in the knowledge base. This will be used for testing and demos.
	- set up the project tracker and calendar with the sprint breakdown and initial tasks for Sprint 0.
	- additional research on deployment with/without gpu support, and the hardware requirements for running the AI models locally.
	- look what github offers for project management.

- Lewin:
	- review the current codebase and documentation to identify any gaps or areas that need improvement.
	- run and test it extensively to identify any issues or blockers that need to be addressed in Sprint 0.

- Daniel:
	- get in touch with bocal to understand the compliance requirements and ensure that our project meets all necessary standards.
	- research on knowledge base and RAG implementations, and how to best integrate them into our stack.
	- how many _modules_ would we still need to fulfill and what can be integrated in a meaningful way?
	- GPU support even needed? Daniel checks with AMD architecture - even meaningful for macstudio? --> Matthias research

-Silvestri:
	- set up the n8n workflows for the email processor and knowledge base ingestion, and test them with the local Ollama instance.
	- Thoughts about what the ERP should consist of, dashboard design, features, etc. --> Research what other ERPs offer, and gather ideas for features we want to implement.


## 6. Next Steps & Action Items
- Schedule next meeting for ### Tuesday, Feb 24, 2026, 18h ###




