# Dependency-ordered program

Generated from planning/catalog.json and shared-system gates in scripts/plan.py. **17 shared-system tickets + 192 lab implementation/qualification tickets.** Existing baseline tickets remain historical. CORE-017 qualifies this planning source only; all lab deepening/new runtime work is specified.

Implementation order is the ticket DAG, not catalog numerical order. A lab's prerequisites must qualify before its dependent A begins. Early-wave development may deliver narrower useful slices while later shared capabilities remain explicitly unavailable.

## Shared systems

| Ticket | Contract | Prerequisites |
|---|---|---|
| [CORE-002](../tickets/CORE-002.md) | Static modules and lifecycle | RELEASE-001 |
| [CORE-003](../tickets/CORE-003.md) | Typed operations, receipts and revisions | CORE-002 |
| [CORE-004](../tickets/CORE-004.md) | Profiles, probes and unavailable routes | CORE-002 |
| [CORE-005](../tickets/CORE-005.md) | Fixtures, namespaces and reset ownership | CORE-003 |
| [CORE-006](../tickets/CORE-006.md) | Source-bound evidence and gate registry | CORE-003, CORE-004 |
| [CORE-007](../tickets/CORE-007.md) | Catalog, inspector and accessible input contexts | CORE-003, CORE-004, CORE-005 |
| [CORE-008](../tickets/CORE-008.md) | Authenticated live transport, CLI and MCP | CORE-003, CORE-005, CORE-006 |
| [CORE-009](../tickets/CORE-009.md) | Simulation clocks, records and replay | CORE-003, CORE-005, CORE-006 |
| [CORE-010](../tickets/CORE-010.md) | Viewer cameras and presentation tracks | CORE-009 |
| [CORE-011](../tickets/CORE-011.md) | One-session Cappy and live orchestration | CORE-008, CORE-009, CORE-010 |
| [CORE-012](../tickets/CORE-012.md) | Budgeted jobs, checkpoints and worker admission | CORE-005, CORE-006 |
| [CORE-013](../tickets/CORE-013.md) | Original asset recipes and interchange pipeline | CORE-005, CORE-006, CORE-012 |
| [CORE-014](../tickets/CORE-014.md) | Media regressions and event derivatives | CORE-006, CORE-009, CORE-011, CORE-012 |
| [CORE-015](../tickets/CORE-015.md) | Session authority and transport harness | CORE-003, CORE-005, CORE-006, CORE-009 |
| [CORE-016](../tickets/CORE-016.md) | Documents, schema migration and recovery | CORE-003, CORE-005 |
| [CORE-017](../tickets/CORE-017.md) | Program catalog and dependency governance | RELEASE-001 |
| [CORE-018](../tickets/CORE-018.md) | Profile exports, budgets and extraction qualification | CORE-004, CORE-006, CORE-012 |

## Laboratory delivery

| Lab / wave | Implementation | Qualification | A prerequisites |
|---|---|---|---|
| LAB-001 / M0 | [LAB-001-A](../tickets/LAB-001-A.md) | [LAB-001-B](../tickets/LAB-001-B.md) | CORE-007, CORE-017, CORE-009 |
| LAB-002 / M0 | [LAB-002-A](../tickets/LAB-002-A.md) | [LAB-002-B](../tickets/LAB-002-B.md) | CORE-007, CORE-017, CORE-009 |
| LAB-003 / M0 | [LAB-003-A](../tickets/LAB-003-A.md) | [LAB-003-B](../tickets/LAB-003-B.md) | CORE-007, CORE-017, CORE-009, CORE-012 |
| LAB-004 / M0 | [LAB-004-A](../tickets/LAB-004-A.md) | [LAB-004-B](../tickets/LAB-004-B.md) | CORE-007, CORE-017, CORE-013 |
| LAB-005 / M0 | [LAB-005-A](../tickets/LAB-005-A.md) | [LAB-005-B](../tickets/LAB-005-B.md) | CORE-007, CORE-017, CORE-010 |
| LAB-006 / M0 | [LAB-006-A](../tickets/LAB-006-A.md) | [LAB-006-B](../tickets/LAB-006-B.md) | CORE-007, CORE-017, CORE-016 |
| LAB-007 / M1 | [LAB-007-A](../tickets/LAB-007-A.md) | [LAB-007-B](../tickets/LAB-007-B.md) | CORE-007, CORE-017, CORE-009, CORE-012, LAB-001-B, LAB-006-B |
| LAB-008 / M1 | [LAB-008-A](../tickets/LAB-008-A.md) | [LAB-008-B](../tickets/LAB-008-B.md) | CORE-007, CORE-017, CORE-009, LAB-001-B |
| LAB-009 / M2 | [LAB-009-A](../tickets/LAB-009-A.md) | [LAB-009-B](../tickets/LAB-009-B.md) | CORE-007, CORE-017, CORE-010, CORE-018, LAB-004-B, LAB-036-B |
| LAB-010 / M2 | [LAB-010-A](../tickets/LAB-010-A.md) | [LAB-010-B](../tickets/LAB-010-B.md) | CORE-007, CORE-017, CORE-010, CORE-018, LAB-004-B, LAB-031-B |
| LAB-011 / M1 | [LAB-011-A](../tickets/LAB-011-A.md) | [LAB-011-B](../tickets/LAB-011-B.md) | CORE-007, CORE-017, CORE-009, LAB-001-B |
| LAB-012 / M1 | [LAB-012-A](../tickets/LAB-012-A.md) | [LAB-012-B](../tickets/LAB-012-B.md) | CORE-007, CORE-017, LAB-001-B, LAB-013-B |
| LAB-013 / M1 | [LAB-013-A](../tickets/LAB-013-A.md) | [LAB-013-B](../tickets/LAB-013-B.md) | CORE-007, CORE-017, LAB-006-B |
| LAB-014 / M1 | [LAB-014-A](../tickets/LAB-014-A.md) | [LAB-014-B](../tickets/LAB-014-B.md) | CORE-007, CORE-017, CORE-016, LAB-006-B, LAB-013-B |
| LAB-015 / M2 | [LAB-015-A](../tickets/LAB-015-A.md) | [LAB-015-B](../tickets/LAB-015-B.md) | CORE-007, CORE-017, CORE-009, LAB-008-B, LAB-035-B |
| LAB-016 / M2 | [LAB-016-A](../tickets/LAB-016-A.md) | [LAB-016-B](../tickets/LAB-016-B.md) | CORE-007, CORE-017, CORE-009, CORE-012, LAB-001-B, LAB-035-B |
| LAB-017 / M2 | [LAB-017-A](../tickets/LAB-017-A.md) | [LAB-017-B](../tickets/LAB-017-B.md) | CORE-007, CORE-017, CORE-012, CORE-018, LAB-036-B |
| LAB-018 / M1 | [LAB-018-A](../tickets/LAB-018-A.md) | [LAB-018-B](../tickets/LAB-018-B.md) | CORE-007, CORE-017, CORE-013, CORE-016, LAB-006-B |
| LAB-019 / M2 | [LAB-019-A](../tickets/LAB-019-A.md) | [LAB-019-B](../tickets/LAB-019-B.md) | CORE-007, CORE-017, CORE-010, CORE-018, LAB-004-B |
| LAB-020 / M2 | [LAB-020-A](../tickets/LAB-020-A.md) | [LAB-020-B](../tickets/LAB-020-B.md) | CORE-007, CORE-017, CORE-010, LAB-005-B |
| LAB-021 / M2 | [LAB-021-A](../tickets/LAB-021-A.md) | [LAB-021-B](../tickets/LAB-021-B.md) | CORE-007, CORE-017, CORE-009, LAB-001-B, LAB-002-B |
| LAB-022 / M2 | [LAB-022-A](../tickets/LAB-022-A.md) | [LAB-022-B](../tickets/LAB-022-B.md) | CORE-007, CORE-017, CORE-009, LAB-002-B, LAB-049-B |
| LAB-023 / M2 | [LAB-023-A](../tickets/LAB-023-A.md) | [LAB-023-B](../tickets/LAB-023-B.md) | CORE-007, CORE-017, CORE-009, CORE-012, LAB-007-B, LAB-006-B |
| LAB-024 / M3 | [LAB-024-A](../tickets/LAB-024-A.md) | [LAB-024-B](../tickets/LAB-024-B.md) | CORE-007, CORE-017, CORE-015, LAB-006-B |
| LAB-025 / M1 | [LAB-025-A](../tickets/LAB-025-A.md) | [LAB-025-B](../tickets/LAB-025-B.md) | CORE-007, CORE-017, CORE-011, CORE-014, LAB-001-B, LAB-004-B, LAB-006-B |
| LAB-026 / M3 | [LAB-026-A](../tickets/LAB-026-A.md) | [LAB-026-B](../tickets/LAB-026-B.md) | CORE-007, CORE-017, CORE-008, CORE-013, LAB-018-B |
| LAB-027 / M4 | [LAB-027-A](../tickets/LAB-027-A.md) | [LAB-027-B](../tickets/LAB-027-B.md) | CORE-007, CORE-017, CORE-008, CORE-013, LAB-036-B, LAB-018-B |
| LAB-028 / M3 | [LAB-028-A](../tickets/LAB-028-A.md) | [LAB-028-B](../tickets/LAB-028-B.md) | CORE-007, CORE-017, CORE-012, CORE-018, LAB-023-B, LAB-036-B |
| LAB-029 / M3 | [LAB-029-A](../tickets/LAB-029-A.md) | [LAB-029-B](../tickets/LAB-029-B.md) | CORE-007, CORE-017, CORE-009, CORE-012, LAB-006-B, LAB-028-B |
| LAB-030 / M4 | [LAB-030-A](../tickets/LAB-030-A.md) | [LAB-030-B](../tickets/LAB-030-B.md) | CORE-007, CORE-017, CORE-009, CORE-012, LAB-029-B, LAB-002-B |
| LAB-031 / M2 | [LAB-031-A](../tickets/LAB-031-A.md) | [LAB-031-B](../tickets/LAB-031-B.md) | CORE-007, CORE-017, CORE-010, CORE-018, LAB-004-B, LAB-036-B |
| LAB-032 / M4 | [LAB-032-A](../tickets/LAB-032-A.md) | [LAB-032-B](../tickets/LAB-032-B.md) | CORE-007, CORE-017, CORE-018, LAB-013-B, LAB-006-B, LAB-094-B |
| LAB-033 / M5 | [LAB-033-A](../tickets/LAB-033-A.md) | [LAB-033-B](../tickets/LAB-033-B.md) | CORE-007, CORE-017, CORE-018, LAB-012-B, LAB-032-B |
| LAB-034 / M5 | [LAB-034-A](../tickets/LAB-034-A.md) | [LAB-034-B](../tickets/LAB-034-B.md) | CORE-007, CORE-017, CORE-018, LAB-001-B, LAB-049-B, LAB-012-B |
| LAB-035 / M2 | [LAB-035-A](../tickets/LAB-035-A.md) | [LAB-035-B](../tickets/LAB-035-B.md) | CORE-007, CORE-017, CORE-013, CORE-016, LAB-018-B, LAB-004-B |
| LAB-036 / M2 | [LAB-036-A](../tickets/LAB-036-A.md) | [LAB-036-B](../tickets/LAB-036-B.md) | CORE-007, CORE-017, CORE-012, CORE-018, LAB-004-B |
| LAB-037 / M1 | [LAB-037-A](../tickets/LAB-037-A.md) | [LAB-037-B](../tickets/LAB-037-B.md) | CORE-007, CORE-017, CORE-016, LAB-013-B, LAB-018-B |
| LAB-038 / M1 | [LAB-038-A](../tickets/LAB-038-A.md) | [LAB-038-B](../tickets/LAB-038-B.md) | CORE-007, CORE-017, CORE-016, LAB-006-B, LAB-025-B |
| LAB-039 / M2 | [LAB-039-A](../tickets/LAB-039-A.md) | [LAB-039-B](../tickets/LAB-039-B.md) | CORE-007, CORE-017, CORE-016, LAB-018-B, LAB-035-B |
| LAB-040 / M3 | [LAB-040-A](../tickets/LAB-040-A.md) | [LAB-040-B](../tickets/LAB-040-B.md) | CORE-007, CORE-017, CORE-016, LAB-021-B, LAB-028-B, LAB-013-B |
| LAB-041 / M1 | [LAB-041-A](../tickets/LAB-041-A.md) | [LAB-041-B](../tickets/LAB-041-B.md) | CORE-007, CORE-017, CORE-016, LAB-038-B |
| LAB-042 / M1 | [LAB-042-A](../tickets/LAB-042-A.md) | [LAB-042-B](../tickets/LAB-042-B.md) | CORE-007, CORE-017, CORE-009, LAB-007-B, LAB-012-B |
| LAB-043 / M2 | [LAB-043-A](../tickets/LAB-043-A.md) | [LAB-043-B](../tickets/LAB-043-B.md) | CORE-007, CORE-017, CORE-009, LAB-008-B, LAB-021-B, LAB-052-B |
| LAB-044 / M2 | [LAB-044-A](../tickets/LAB-044-A.md) | [LAB-044-B](../tickets/LAB-044-B.md) | CORE-007, CORE-017, CORE-009, LAB-001-B, LAB-008-B, LAB-011-B |
| LAB-045 / M2 | [LAB-045-A](../tickets/LAB-045-A.md) | [LAB-045-B](../tickets/LAB-045-B.md) | CORE-007, CORE-017, CORE-009, LAB-001-B, LAB-021-B |
| LAB-046 / M3 | [LAB-046-A](../tickets/LAB-046-A.md) | [LAB-046-B](../tickets/LAB-046-B.md) | CORE-007, CORE-017, CORE-009, LAB-052-B, LAB-053-B |
| LAB-047 / M3 | [LAB-047-A](../tickets/LAB-047-A.md) | [LAB-047-B](../tickets/LAB-047-B.md) | CORE-007, CORE-017, CORE-009, LAB-003-B, LAB-024-B |
| LAB-048 / M2 | [LAB-048-A](../tickets/LAB-048-A.md) | [LAB-048-B](../tickets/LAB-048-B.md) | CORE-007, CORE-017, CORE-009, LAB-042-B |
| LAB-049 / M2 | [LAB-049-A](../tickets/LAB-049-A.md) | [LAB-049-B](../tickets/LAB-049-B.md) | CORE-007, CORE-017, CORE-009, LAB-002-B |
| LAB-050 / M2 | [LAB-050-A](../tickets/LAB-050-A.md) | [LAB-050-B](../tickets/LAB-050-B.md) | CORE-007, CORE-017, CORE-009, LAB-002-B, LAB-052-B |
| LAB-051 / M3 | [LAB-051-A](../tickets/LAB-051-A.md) | [LAB-051-B](../tickets/LAB-051-B.md) | CORE-007, CORE-017, CORE-009, LAB-002-B, LAB-035-B |
| LAB-052 / M1 | [LAB-052-A](../tickets/LAB-052-A.md) | [LAB-052-B](../tickets/LAB-052-B.md) | CORE-007, CORE-017, CORE-009, LAB-001-B, LAB-002-B |
| LAB-053 / M3 | [LAB-053-A](../tickets/LAB-053-A.md) | [LAB-053-B](../tickets/LAB-053-B.md) | CORE-007, CORE-017, CORE-009, LAB-002-B, LAB-052-B |
| LAB-054 / M3 | [LAB-054-A](../tickets/LAB-054-A.md) | [LAB-054-B](../tickets/LAB-054-B.md) | CORE-007, CORE-017, CORE-009, LAB-015-B, LAB-049-B, LAB-008-B |
| LAB-055 / M2 | [LAB-055-A](../tickets/LAB-055-A.md) | [LAB-055-B](../tickets/LAB-055-B.md) | CORE-007, CORE-017, CORE-009, CORE-012, LAB-007-B, LAB-038-B |
| LAB-056 / M3 | [LAB-056-A](../tickets/LAB-056-A.md) | [LAB-056-B](../tickets/LAB-056-B.md) | CORE-007, CORE-017, CORE-009, CORE-012, LAB-016-B, LAB-028-B, LAB-029-B |
| LAB-057 / M3 | [LAB-057-A](../tickets/LAB-057-A.md) | [LAB-057-B](../tickets/LAB-057-B.md) | CORE-007, CORE-017, CORE-009, CORE-012, LAB-003-B, LAB-028-B |
| LAB-058 / M2 | [LAB-058-A](../tickets/LAB-058-A.md) | [LAB-058-B](../tickets/LAB-058-B.md) | CORE-007, CORE-017, CORE-009, CORE-012, LAB-021-B, LAB-041-B |
| LAB-059 / M3 | [LAB-059-A](../tickets/LAB-059-A.md) | [LAB-059-B](../tickets/LAB-059-B.md) | CORE-007, CORE-017, CORE-012, CORE-018, LAB-017-B, LAB-036-B, LAB-011-B |
| LAB-060 / M2 | [LAB-060-A](../tickets/LAB-060-A.md) | [LAB-060-B](../tickets/LAB-060-B.md) | CORE-007, CORE-017, CORE-013, LAB-004-B, LAB-035-B |
| LAB-061 / M2 | [LAB-061-A](../tickets/LAB-061-A.md) | [LAB-061-B](../tickets/LAB-061-B.md) | CORE-007, CORE-017, CORE-013, LAB-004-B, LAB-035-B |
| LAB-062 / M2 | [LAB-062-A](../tickets/LAB-062-A.md) | [LAB-062-B](../tickets/LAB-062-B.md) | CORE-007, CORE-017, CORE-013, LAB-011-B, LAB-035-B |
| LAB-063 / M2 | [LAB-063-A](../tickets/LAB-063-A.md) | [LAB-063-B](../tickets/LAB-063-B.md) | CORE-007, CORE-017, CORE-013, LAB-008-B, LAB-021-B |
| LAB-064 / M2 | [LAB-064-A](../tickets/LAB-064-A.md) | [LAB-064-B](../tickets/LAB-064-B.md) | CORE-007, CORE-017, CORE-013, LAB-010-B, LAB-060-B |
| LAB-065 / M3 | [LAB-065-A](../tickets/LAB-065-A.md) | [LAB-065-B](../tickets/LAB-065-B.md) | CORE-007, CORE-017, CORE-010, CORE-018, LAB-010-B, LAB-031-B |
| LAB-066 / M3 | [LAB-066-A](../tickets/LAB-066-A.md) | [LAB-066-B](../tickets/LAB-066-B.md) | CORE-007, CORE-017, CORE-010, CORE-018, LAB-011-B, LAB-013-B |
| LAB-067 / M3 | [LAB-067-A](../tickets/LAB-067-A.md) | [LAB-067-B](../tickets/LAB-067-B.md) | CORE-007, CORE-017, CORE-010, CORE-018, LAB-031-B, LAB-060-B |
| LAB-068 / M2 | [LAB-068-A](../tickets/LAB-068-A.md) | [LAB-068-B](../tickets/LAB-068-B.md) | CORE-007, CORE-017, CORE-010, CORE-018, LAB-004-B, LAB-019-B, LAB-013-B |
| LAB-069 / M4 | [LAB-069-A](../tickets/LAB-069-A.md) | [LAB-069-B](../tickets/LAB-069-B.md) | CORE-007, CORE-017, CORE-010, CORE-018, LAB-027-B, LAB-031-B, LAB-028-B |
| LAB-070 / M3 | [LAB-070-A](../tickets/LAB-070-A.md) | [LAB-070-B](../tickets/LAB-070-B.md) | CORE-007, CORE-017, CORE-010, CORE-018, LAB-010-B, LAB-031-B, LAB-019-B |
| LAB-071 / M2 | [LAB-071-A](../tickets/LAB-071-A.md) | [LAB-071-B](../tickets/LAB-071-B.md) | CORE-007, CORE-017, CORE-010, LAB-005-B, LAB-020-B |
| LAB-072 / M3 | [LAB-072-A](../tickets/LAB-072-A.md) | [LAB-072-B](../tickets/LAB-072-B.md) | CORE-007, CORE-017, CORE-010, LAB-071-B, LAB-021-B |
| LAB-073 / M3 | [LAB-073-A](../tickets/LAB-073-A.md) | [LAB-073-B](../tickets/LAB-073-B.md) | CORE-007, CORE-017, CORE-010, LAB-014-B, LAB-071-B |
| LAB-074 / M2 | [LAB-074-A](../tickets/LAB-074-A.md) | [LAB-074-B](../tickets/LAB-074-B.md) | CORE-007, CORE-017, CORE-016, LAB-038-B, LAB-041-B, LAB-021-B |
| LAB-075 / M2 | [LAB-075-A](../tickets/LAB-075-A.md) | [LAB-075-B](../tickets/LAB-075-B.md) | CORE-007, CORE-017, CORE-016, LAB-074-B, LAB-038-B, LAB-006-B |
| LAB-076 / M3 | [LAB-076-A](../tickets/LAB-076-A.md) | [LAB-076-B](../tickets/LAB-076-B.md) | CORE-007, CORE-017, CORE-016, LAB-011-B, LAB-008-B, LAB-025-B |
| LAB-077 / M2 | [LAB-077-A](../tickets/LAB-077-A.md) | [LAB-077-B](../tickets/LAB-077-B.md) | CORE-007, CORE-017, CORE-016, LAB-018-B, LAB-038-B, LAB-006-B |
| LAB-078 / M3 | [LAB-078-A](../tickets/LAB-078-A.md) | [LAB-078-B](../tickets/LAB-078-B.md) | CORE-007, CORE-017, LAB-013-B, LAB-006-B |
| LAB-079 / M3 | [LAB-079-A](../tickets/LAB-079-A.md) | [LAB-079-B](../tickets/LAB-079-B.md) | CORE-007, CORE-017, LAB-013-B, LAB-066-B |
| LAB-080 / M2 | [LAB-080-A](../tickets/LAB-080-A.md) | [LAB-080-B](../tickets/LAB-080-B.md) | CORE-007, CORE-017, LAB-012-B, LAB-013-B, LAB-006-B, LAB-068-B |
| LAB-081 / M2 | [LAB-081-A](../tickets/LAB-081-A.md) | [LAB-081-B](../tickets/LAB-081-B.md) | CORE-007, CORE-017, LAB-013-B, LAB-018-B, LAB-038-B |
| LAB-082 / M4 | [LAB-082-A](../tickets/LAB-082-A.md) | [LAB-082-B](../tickets/LAB-082-B.md) | CORE-007, CORE-017, CORE-015, LAB-024-B, LAB-025-B, LAB-001-B |
| LAB-083 / M4 | [LAB-083-A](../tickets/LAB-083-A.md) | [LAB-083-B](../tickets/LAB-083-B.md) | CORE-007, CORE-017, CORE-015, LAB-024-B, LAB-082-B, LAB-006-B |
| LAB-084 / M4 | [LAB-084-A](../tickets/LAB-084-A.md) | [LAB-084-B](../tickets/LAB-084-B.md) | CORE-007, CORE-017, CORE-015, LAB-024-B, LAB-082-B, LAB-083-B |
| LAB-085 / M4 | [LAB-085-A](../tickets/LAB-085-A.md) | [LAB-085-B](../tickets/LAB-085-B.md) | CORE-007, CORE-017, CORE-015, LAB-024-B, LAB-038-B |
| LAB-086 / M5 | [LAB-086-A](../tickets/LAB-086-A.md) | [LAB-086-B](../tickets/LAB-086-B.md) | CORE-007, CORE-017, CORE-015, LAB-024-B, LAB-032-B, LAB-085-B |
| LAB-087 / M3 | [LAB-087-A](../tickets/LAB-087-A.md) | [LAB-087-B](../tickets/LAB-087-B.md) | CORE-007, CORE-017, CORE-011, CORE-014, LAB-038-B, LAB-025-B, LAB-040-B |
| LAB-088 / M3 | [LAB-088-A](../tickets/LAB-088-A.md) | [LAB-088-B](../tickets/LAB-088-B.md) | CORE-007, CORE-017, CORE-011, CORE-014, LAB-025-B, LAB-087-B, LAB-039-B |
| LAB-089 / M3 | [LAB-089-A](../tickets/LAB-089-A.md) | [LAB-089-B](../tickets/LAB-089-B.md) | CORE-007, CORE-017, CORE-011, CORE-014, LAB-028-B, LAB-088-B, LAB-036-B |
| LAB-090 / M3 | [LAB-090-A](../tickets/LAB-090-A.md) | [LAB-090-B](../tickets/LAB-090-B.md) | CORE-007, CORE-017, CORE-011, CORE-014, LAB-011-B, LAB-076-B, LAB-088-B |
| LAB-091 / M4 | [LAB-091-A](../tickets/LAB-091-A.md) | [LAB-091-B](../tickets/LAB-091-B.md) | CORE-007, CORE-017, CORE-011, CORE-014, LAB-088-B, LAB-073-B, LAB-019-B |
| LAB-092 / M3 | [LAB-092-A](../tickets/LAB-092-A.md) | [LAB-092-B](../tickets/LAB-092-B.md) | CORE-007, CORE-017, CORE-012, CORE-018, LAB-029-B, LAB-017-B, LAB-040-B, LAB-036-B |
| LAB-093 / M3 | [LAB-093-A](../tickets/LAB-093-A.md) | [LAB-093-B](../tickets/LAB-093-B.md) | CORE-007, CORE-017, CORE-008, CORE-013, LAB-026-B, LAB-018-B, LAB-039-B |
| LAB-094 / M4 | [LAB-094-A](../tickets/LAB-094-A.md) | [LAB-094-B](../tickets/LAB-094-B.md) | CORE-007, CORE-017, CORE-008, CORE-013, LAB-026-B, LAB-088-B |
| LAB-095 / M3 | [LAB-095-A](../tickets/LAB-095-A.md) | [LAB-095-B](../tickets/LAB-095-B.md) | CORE-007, CORE-017, CORE-013, CORE-016, LAB-035-B, LAB-015-B, LAB-060-B, LAB-061-B |
| LAB-096 / M5 | [LAB-096-A](../tickets/LAB-096-A.md) | [LAB-096-B](../tickets/LAB-096-B.md) | CORE-007, CORE-017, CORE-018, LAB-034-B, LAB-015-B, LAB-012-B |

## Dependency-ready layers

RELEASE-001 is the existing qualified prerequisite. Each layer is eligible only after earlier dependencies close; a layer is not a promise to use every machine at once. CORE-017 is already qualified as planning tooling. Runtime/resource/provider jobs require admission and ownership.

1. CORE-002, CORE-017

2. CORE-003, CORE-004

3. CORE-005, CORE-006

4. CORE-007, CORE-008, CORE-009, CORE-012, CORE-016

5. CORE-010, CORE-013, CORE-015, CORE-018, LAB-001-A, LAB-002-A, LAB-003-A, LAB-006-A

6. CORE-011, LAB-001-B, LAB-002-B, LAB-003-B, LAB-004-A, LAB-005-A, LAB-006-B

7. CORE-014, LAB-004-B, LAB-005-B, LAB-007-A, LAB-008-A, LAB-011-A, LAB-013-A, LAB-018-A, LAB-021-A, LAB-024-A, LAB-049-A, LAB-052-A

8. LAB-007-B, LAB-008-B, LAB-011-B, LAB-013-B, LAB-018-B, LAB-019-A, LAB-020-A, LAB-021-B, LAB-024-B, LAB-025-A, LAB-036-A, LAB-049-B, LAB-052-B

9. LAB-012-A, LAB-014-A, LAB-019-B, LAB-020-B, LAB-022-A, LAB-023-A, LAB-025-B, LAB-026-A, LAB-035-A, LAB-036-B, LAB-037-A, LAB-043-A, LAB-044-A, LAB-045-A, LAB-047-A, LAB-050-A, LAB-053-A, LAB-063-A, LAB-066-A, LAB-078-A

10. LAB-009-A, LAB-012-B, LAB-014-B, LAB-017-A, LAB-022-B, LAB-023-B, LAB-026-B, LAB-027-A, LAB-031-A, LAB-035-B, LAB-037-B, LAB-038-A, LAB-043-B, LAB-044-B, LAB-045-B, LAB-047-B, LAB-050-B, LAB-053-B, LAB-063-B, LAB-066-B, LAB-068-A, LAB-071-A, LAB-076-A, LAB-078-B, LAB-082-A

11. LAB-009-B, LAB-015-A, LAB-016-A, LAB-017-B, LAB-027-B, LAB-028-A, LAB-031-B, LAB-034-A, LAB-038-B, LAB-039-A, LAB-042-A, LAB-046-A, LAB-051-A, LAB-060-A, LAB-061-A, LAB-062-A, LAB-068-B, LAB-071-B, LAB-076-B, LAB-079-A, LAB-082-B

12. LAB-010-A, LAB-015-B, LAB-016-B, LAB-028-B, LAB-034-B, LAB-039-B, LAB-041-A, LAB-042-B, LAB-046-B, LAB-051-B, LAB-055-A, LAB-059-A, LAB-060-B, LAB-061-B, LAB-062-B, LAB-072-A, LAB-073-A, LAB-077-A, LAB-079-B, LAB-080-A, LAB-081-A, LAB-083-A, LAB-085-A

13. LAB-010-B, LAB-029-A, LAB-040-A, LAB-041-B, LAB-048-A, LAB-054-A, LAB-055-B, LAB-057-A, LAB-059-B, LAB-067-A, LAB-069-A, LAB-072-B, LAB-073-B, LAB-077-B, LAB-080-B, LAB-081-B, LAB-083-B, LAB-085-B, LAB-093-A, LAB-095-A, LAB-096-A

14. LAB-029-B, LAB-040-B, LAB-048-B, LAB-054-B, LAB-057-B, LAB-058-A, LAB-064-A, LAB-065-A, LAB-067-B, LAB-069-B, LAB-070-A, LAB-074-A, LAB-084-A, LAB-093-B, LAB-095-B, LAB-096-B

15. LAB-030-A, LAB-056-A, LAB-058-B, LAB-064-B, LAB-065-B, LAB-070-B, LAB-074-B, LAB-084-B, LAB-087-A, LAB-092-A

16. LAB-030-B, LAB-056-B, LAB-075-A, LAB-087-B, LAB-092-B

17. LAB-075-B, LAB-088-A

18. LAB-088-B

19. LAB-089-A, LAB-090-A, LAB-091-A, LAB-094-A

20. LAB-089-B, LAB-090-B, LAB-091-B, LAB-094-B

21. LAB-032-A

22. LAB-032-B

23. LAB-033-A, LAB-086-A

24. LAB-033-B, LAB-086-B
