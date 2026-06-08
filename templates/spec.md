# Spec: {{DOMAIN_NAME}}

> 本规范描述 {{DOMAIN_NAME}} 领域的行为。它是该领域功能的真相源。

## User Stories

<!-- 按优先级排列，每个 User Story 应可独立测试 -->

### US-1: {{USER_STORY_TITLE}} (P1)

**As a** {{USER_TYPE}},
**I want** {{GOAL}},
**So that** {{BENEFIT}}.

**Acceptance Scenarios**:

1. **Given** {{PRECONDITION}}, **When** {{ACTION}}, **Then** {{EXPECTED_RESULT}}
2. **Given** {{PRECONDITION}}, **When** {{ACTION}}, **Then** {{EXPECTED_RESULT}}

---

### US-2: {{USER_STORY_TITLE}} (P2)

**As a** {{USER_TYPE}},
**I want** {{GOAL}},
**So that** {{BENEFIT}}.

**Acceptance Scenarios**:

1. **Given** {{PRECONDITION}}, **When** {{ACTION}}, **Then** {{EXPECTED_RESULT}}

---

## Functional Requirements

<!-- 使用 RFC 2119 关键词：SHALL, MUST, SHOULD, MAY -->

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-001 | The system SHALL {{REQUIREMENT}} | P1 | Proposed |
| FR-002 | The system MUST {{REQUIREMENT}} | P1 | Proposed |
| FR-003 | The system SHOULD {{REQUIREMENT}} | P2 | Proposed |

## Key Entities

<!-- 领域概念建模（不涉及具体数据库/框架） -->

| Entity | Description | Key Attributes |
|--------|-------------|----------------|
| {{ENTITY}} | {{DESCRIPTION}} | {{ATTRIBUTES}} |

## Success Criteria

<!-- 可量化、技术无关的成功指标 -->

| ID | Criterion | Measurement |
|----|-----------|-------------|
| SC-001 | {{CRITERION}} | {{HOW_TO_MEASURE}} |

## Assumptions

<!-- 规范编写时做出的合理假设 -->

1. {{ASSUMPTION}}
2. {{ASSUMPTION}}

## Dependencies

<!-- 本规范依赖的其他规范 -->

- `leaspec/specs/{{dependency}}.md`

---

**Version**: 1.0.0
**Created**: {{DATE}}
**Last Updated**: {{DATE}}
