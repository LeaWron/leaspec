# Design: {{FEATURE_NAME}}

## Summary

<!-- 1-2 段概述技术方案 -->

## Technical Context

| Aspect | Choice |
|--------|--------|
| Language / Runtime | {{LANGUAGE}} |
| Framework | {{FRAMEWORK}} |
| Storage | {{STORAGE}} |
| External Dependencies | {{DEPS}} |
| Target Platform | {{PLATFORM}} |

## Architecture

<!-- 架构决策说明 -->

### Decision 1: {{DECISION_TITLE}}

**Context**: {{CONTEXT}}
**Options Considered**:
1. {{OPTION_1}} — {{TRADEOFFS}}
2. {{OPTION_2}} — {{TRADEOFFS}}
**Decision**: {{CHOSEN_OPTION}}
**Rationale**: {{WHY}}

### Decision 2: {{DECISION_TITLE}}

...

## Project Structure

```
src/
├── {{module_a}}/
│   ├── __tests__/
│   └── ...
├── {{module_b}}/
│   ├── __tests__/
│   └── ...
└── ...
```

## Constitution Check

<!-- 从当前项目的 leaspec/constitution.md 读取 Core Principles，并逐条检查。以下为默认 leaspec 宪法示例。 -->

| Gate | Status | Notes |
|------|--------|-------|
| Spec-as-Truth | ✅ / ⚠️ | {{NOTES}} |
| Trigger-by-Need | ✅ / ⚠️ | {{NOTES}} |
| Incremental-First | ✅ / ⚠️ | {{NOTES}} |
| Design-Before-Code | ✅ / ⚠️ | {{NOTES}} |
| Simplicity | ✅ / ⚠️ | {{NOTES}} |
| Respect-Comments | ✅ / ⚠️ | {{NOTES}} |

## Complexity Tracking

<!-- 记录违反宪法原则的例外情况及其理由 -->

| Violation | Reason | Mitigation |
|-----------|--------|------------|
| | | |

## Data Flow

<!-- 关键数据流描述 -->

## API Contracts

<!-- 如有 API 变更，引用到 contracts/ 中的具体文件 -->

## Testing Strategy

<!-- 测试方案概述 -->
