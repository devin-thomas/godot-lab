"""Validate and generate the specified program without changing runtime registration."""
from __future__ import annotations

import argparse
import copy
import json
import re
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WINGS = (
    "core", "motion", "simulation", "world", "art", "rendering", "audio",
    "narrative", "interfaces", "networking", "automation", "tooling",
    "performance", "interchange", "platforms", "xr",
)
EVIDENCE = {"logic", "render", "audio", "provider", "export", "physical",
            "profiling", "editor", "transport", "interchange"}
BASELINE_SCENARIOS = ("motion", "physics", "navigation", "materials", "audio", "persistence")
BASELINE_COMMIT = "ad7d305f4f8057296cf75cacd6624c6d329bf236"
LEGACY_TITLES = (
    "Motion atelier", "Gravity foundry", "Pathfinder garden", "Paint & light", "Signal chamber", "Memory archive",
    "Tile Workshop", "Animation Loom", "Particle Weather", "Light Archive", "Camera Rig", "Input Atelier",
    "UI Workshop", "Dialogue Machine", "Skeleton Studio", "Terrain Foundry", "Crowd Balcony", "Resource Cabinet",
    "Shader Bench", "Acoustic Rooms", "Time Laboratory", "Destruction Cell", "Procedural Garden", "Network Commons",
    "Replay Observatory", "Editor Toolroom", "Native Bridge", "Thread Mill", "Streaming Depot", "Large World",
    "Renderer Gallery", "Web Portal", "Mobile Field Kit", "XR Room", "Import Studio", "Profiling Booth",
)
# These describe future shared-system work. CORE-001 and RELEASE-001 are the baseline.
CORE = [
    ("CORE-002", "Static modules and lifecycle", ["RELEASE-001"],
     "Migrate the six scenes to injected modules without changing seals, controls or scenario semantics.",
     ["Extraction scene boots without museum paths", "Repeated entry/reset/exit releases owned nodes, signals and audio", "Existing six-room assertions remain passing"]),
    ("CORE-003", "Typed operations, receipts and revisions", ["CORE-002"],
     "One validated operation bus drives UI and scenarios; receipts distinguish queued and completed effects.",
     ["Equivalent UI/scenario results", "Invalid args and conflicting duplicate request IDs reject before mutation", "Retry/stale revision tests preserve durable state"]),
    ("CORE-004", "Profiles, probes and unavailable routes", ["CORE-002"],
     "Probe actual build/renderer/provider/assets/adapters and show useful labeled fallbacks.",
     ["Unavailable adapter cannot break CoreLocal", "Probe reports exact route/reason", "No untested physical support badges"]),
    ("CORE-005", "Fixtures, namespaces and reset ownership", ["CORE-003"],
     "Register original hashed fixtures and stage bounded hostile imports; reset cancels only owned work.",
     ["Cross-lab progress survives reset", "Oversize/traversal/malformed fixtures reject safely", "Exit during work leaves no ownerless actor or partial success"]),
    ("CORE-006", "Source-bound evidence and gate registry", ["CORE-003", "CORE-004"],
     "Bind results/artifacts to source, fixture, toolchain, scenario, profile and declared limits.",
     ["Stale-build/fixture proof is rejected", "Missing audio/pixels/provider cannot masquerade as logic proof", "Public reports exclude secrets and private routes"]),
    ("CORE-007", "Catalog, inspector and accessible input contexts", ["CORE-003", "CORE-004", "CORE-005"],
     "Provide searchable specification/readiness, parameters, receipts, keyboard focus and comfort controls.",
     ["Specified labs are not live portals", "Context changes release stuck actions and restore focus", "Text/shape cues and reduced motion remain useful"]),
    ("CORE-008", "Authenticated live transport, CLI and MCP", ["CORE-003", "CORE-005", "CORE-006"],
     "Expose bounded loopback operations, observations/events and clients through the shared spine.",
     ["Unauthenticated mutations, unknown ops and oversized requests fail", "Disconnect/retry/cursor gap has explicit behavior", "UI/CLI/MCP/live routes have semantic parity"]),
    ("CORE-009", "Simulation clocks, records and replay", ["CORE-003", "CORE-005", "CORE-006"],
     "Order fixed-tick commands, checkpoints and semantic events separately from presentation time.",
     ["Same-tick ordering and pause/time-scale boundaries tested", "Incompatible/tampered record rejected", "Replay uses declared per-system tolerance"]),
    ("CORE-010", "Viewer cameras and presentation tracks", ["CORE-009"],
     "Author independent framing/look/effect tracks anchored to simulation events.",
     ["Changing viewer camera leaves simulation result intact", "Invalid tracks/cameras fail visibly", "Output rates and event timing verified in actual frames"]),
    ("CORE-011", "One-session Cappy and live orchestration", ["CORE-008", "CORE-009", "CORE-010"],
     "Extend pinned official Cappy integration so live authoring, replay and capture coexist in one session.",
     ["Agent changes real scene during game-only capture", "Decoded video/audio aligns with recorded operations", "Provider loss/stop cleans up without fake success"]),
    ("CORE-012", "Budgeted jobs, checkpoints and worker admission", ["CORE-005", "CORE-006"],
     "Bound and cancel authoring/render/analysis jobs with capacity checks and source/recipe identity.",
     ["Cancellation preserves previous good output", "Resume rejects incompatible source/fixture", "Unavailable or full worker yields truthful failure without local overload"]),
    ("CORE-013", "Original asset recipes and interchange pipeline", ["CORE-005", "CORE-006", "CORE-012"],
     "Automate Blender authoring/import and validate meshes, UVs, colors, materials, rigs and clips.",
     ["Round trips preserve declared semantic structure", "Broken rig/missing clip/license rejected", "Hash manifest and extraction scene reproduce recipe"]),
    ("CORE-014", "Media regressions and event derivatives", ["CORE-006", "CORE-009", "CORE-011", "CORE-012"],
     "Analyze actual video/audio, compare source-bound runs and produce event-anchored clips.",
     ["Black/frozen/silent/misaligned negative controls fail", "Comparison aligns fixture/look/renderer and declares tolerance", "Voice transcription used only when speech is actually present"]),
    ("CORE-015", "Session authority and transport harness", ["CORE-003", "CORE-005", "CORE-006", "CORE-009"],
     "Define real peer roles, authority, ordered commands/replaceable samples and loss/reconnect harness.",
     ["Unauthorized peer cannot mutate world", "Late/duplicate/lost messages follow contract", "Real separate peers resync with declared tolerance"]),
    ("CORE-016", "Documents, schema migration and recovery", ["CORE-003", "CORE-005"],
     "Separate progress/documents/records; stage migrations and atomically publish portable experiments.",
     ["Current schema-1 save stays compatible", "Unknown/newer/truncated data preserves good state", "Restart/round-trip/scoped reset use real files"]),
    ("CORE-017", "Program catalog and dependency governance", ["RELEASE-001"],
     "Keep 96 detailed interaction contracts, generated tickets/matrices and failure-probed DAG validation.",
     ["Duplicate/cycle/unknown dependency/status inflation negative controls reject", "Generated drift and dangling local links reject", "No new runtime claims from planning generation"]),
    ("CORE-018", "Profile exports, budgets and extraction qualification", ["CORE-004", "CORE-006", "CORE-012"],
     "Qualify actual source/export/toolchain routes and minimal component hosts for each supported profile.",
     ["Clean public archive has no sibling dependence", "Unsupported target/renderer remains explicitly unqualified", "Memory/timing/resource evidence and licenses accompany release"]),
]
WING_GATES = {
    "core": ["CORE-016"], "motion": ["CORE-009"], "simulation": ["CORE-009"],
    "world": ["CORE-009", "CORE-012"], "art": ["CORE-013"],
    "rendering": ["CORE-010", "CORE-018"], "audio": ["CORE-010"],
    "narrative": ["CORE-016"], "interfaces": ["CORE-007"],
    "networking": ["CORE-015"], "automation": ["CORE-011", "CORE-014"],
    "tooling": ["CORE-008", "CORE-013"], "performance": ["CORE-012", "CORE-018"],
    "interchange": ["CORE-013", "CORE-016"], "platforms": ["CORE-018"], "xr": ["CORE-018"],
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def ordered(graph: dict[str, list[str]], external: set[str] | None = None) -> list[list[str]]:
    done = set(external or ())
    unknown = {d for deps in graph.values() for d in deps} - set(graph) - done
    require(not unknown, f"unknown dependencies: {sorted(unknown)}")
    pending = dict(graph)
    layers = []
    while pending:
        ready = sorted(k for k, deps in pending.items() if set(deps) <= done)
        require(bool(ready), f"dependency cycle: {sorted(pending)}")
        layers.append(ready)
        done.update(ready)
        for key in ready:
            del pending[key]
    return layers


def validate(labs: list[dict]) -> None:
    require(isinstance(labs, list) and len(labs) == 96, "catalog must contain 96 lab objects")
    expected = [f"LAB-{i:03}" for i in range(1, 97)]
    require([lab.get("id") for lab in labs] == expected, "IDs must be unique, ordered LAB-001..096")
    require(tuple(lab.get("title") for lab in labs[:36]) == LEGACY_TITLES, "legacy lab identities changed")
    require({lab.get("wing") for lab in labs} == set(WINGS), "catalog must cover all 16 known wings")
    scenarios = set()
    for number, lab in enumerate(labs, 1):
        label = lab["id"]
        for field in ("title", "payoff", "scenario", "fixture", "reset", "reusable_component", "limits"):
            require(isinstance(lab.get(field), str) and bool(lab[field].strip()), f"{label}: missing {field}")
        for field, minimum in (("mechanism", 1), ("interaction", 3), ("operations", 1),
                               ("acceptance", 3), ("failures", 2), ("evidence", 1)):
            value = lab.get(field)
            require(isinstance(value, list) and len(value) >= minimum and
                    all(isinstance(x, str) and x.strip() for x in value), f"{label}: incomplete {field}")
        require(lab.get("milestone") in {f"M{i}" for i in range(6)}, f"{label}: invalid milestone")
        require(set(lab["evidence"]) <= EVIDENCE, f"{label}: unknown evidence channel")
        require(len(set(lab["operations"])) == len(lab["operations"]), f"{label}: duplicate operation")
        require(all(re.fullmatch(r"[a-z][a-z0-9_.-]*\.[a-z][a-z0-9_.-]*", op.split("(", 1)[0])
                    for op in lab["operations"]), f"{label}: operations must be namespaced")
        require(lab["scenario"] not in scenarios, f"{label}: duplicate scenario")
        scenarios.add(lab["scenario"])
        require(isinstance(lab.get("depends_on"), list) and
                all(d in expected and d != label for d in lab["depends_on"]), f"{label}: invalid dependency")
        if number <= 6:
            require(lab["status"] == "automated-verified" and lab["milestone"] == "M0", f"{label}: baseline changed")
            require(lab["scenario"] == BASELINE_SCENARIOS[number-1], f"{label}: baseline scenario changed")
            require(isinstance(lab.get("deepening_requirements"), list) and len(lab["deepening_requirements"]) >= 3,
                    f"{label}: missing separate depth contract")
        else:
            require(lab["status"] == "specified" and lab["milestone"] != "M0", f"{label}: unsupported runtime promotion")
    ordered({lab["id"]: lab["depends_on"] for lab in labs})
    by_id = {lab["id"]: lab for lab in labs}
    for lab in labs:
        for dep in lab["depends_on"]:
            require(by_id[dep]["milestone"] <= lab["milestone"], f"{lab['id']}: dependency {dep} is in a later wave")


def ticket_graph(labs: list[dict]) -> dict[str, list[str]]:
    graph = {key: deps for key, _, deps, _, _ in CORE}
    for lab in labs:
        key = lab["id"]
        graph[key + "-A"] = list(dict.fromkeys(
            ["CORE-007", "CORE-017"] + WING_GATES[lab["wing"]] + [dep + "-B" for dep in lab["depends_on"]]))
        graph[key + "-B"] = [key + "-A", "CORE-006", "CORE-018"]
    ordered(graph, {"RELEASE-001"})
    return graph


def bullets(items: list[str]) -> str:
    return "\n".join(f"- {item}" for item in items)


def expansion(lab: dict) -> str:
    key = lab["id"]
    deps = ", ".join(f"[{d}]({d}.md)" for d in lab["depends_on"]) or "None"
    depth = ("\n\n### Separate depth requirements\n\n" + bullets(lab["deepening_requirements"])) if lab.get("deepening_requirements") else ""
    return f"""## Expansion interaction contract

Wing: {lab['wing']}. Planned wave: {'M1 baseline deepening; see dependency order' if lab['milestone'] == 'M0' else lab['milestone']}.
**All operations and expanded assertions below are specified work.** The six bootstrap routes have separate historical proof; new depth has none yet.

### Player payoff

{lab['payoff']}

### Mechanisms and operations

Mechanism leads (verify installed APIs; lab-owned types/contracts are proposals):

{bullets(lab['mechanism'])}

Proposed typed operations, shared by player UI and supported scenario/CLI/live/MCP adapters:

{bullets([f'`{op}`' for op in lab['operations']])}

Before A closes, specify each operation's bounded argument/result schema, readiness, revision/idempotency, event effects and cancellation behavior in source. Names alone are not an implementation.

### Interaction

{chr(10).join(f'{i}. {step}' for i, step in enumerate(lab['interaction'], 1))}

### Fixture, reset and unavailable path

Scenario: `{lab['scenario']}`. Fixture: {lab['fixture']}

Reset ownership: {lab['reset']}

Limits and unavailable route: {lab['limits']}

Use original bounded fixtures with hash/license/seed manifests. Readiness must name the actual missing adapter and a useful labeled fallback if possible. Fixture replay does not establish device/provider support.

### Positive acceptance

{bullets(lab['acceptance'])}

### Failure and negative controls

{bullets(lab['failures'])}

Additionally exercise reset/exit during the longest operation, repeated entry and fixture isolation. Observe real mechanisms; never assign the expected final result to make the assertion pass.

### Evidence and reuse

Required channels: {', '.join(lab['evidence'])}. See [evidence gates](../docs/TEST_STRATEGY.md). Before B closes, define precise assertions/tolerances, record actual source/profile/tool/fixture identity, and distinguish available automatic routes from deferred physical/human gates.

Reusable component: {lab['reusable_component']}

Qualify this component in a minimal scene outside the museum with injected dependencies. The source and instructions must identify its actual extraction path.

### Delivery

Lab prerequisites: {deps}.
Implementation/deepening: [{key}-A](../tickets/{key}-A.md). Qualification: [{key}-B](../tickets/{key}-B.md).
Shared prerequisites and topological order: [ROADMAP](../docs/ROADMAP.md).

Source leads: {', '.join(f'[Primary documentation]({source})' for source in lab.get('sources', []))}.
Implementation boundary: {lab.get('implementation_boundary', 'Specified expansion; installed API and target probes required.')}
{depth}
"""


def validate_journeys(journeys: list[dict], labs: list[dict]) -> None:
    require(isinstance(journeys, list) and len(journeys) == 8, "eight public journeys required")
    require([j.get("id") for j in journeys] == [f"JOURNEY-{i:03}" for i in range(1, 9)], "journey IDs invalid")
    by_id = {lab["id"]: lab for lab in labs}
    for journey in journeys:
        require(isinstance(journey.get("labs"), list) and len(set(journey["labs"])) >= 3 and
                all(key in by_id for key in journey["labs"]), f"{journey['id']}: invalid prerequisites")
        for field in ("title", "goal", "handoff"):
            require(isinstance(journey.get(field), str) and journey[field].strip(), f"missing journey {field}")
        for field in ("flow", "acceptance", "failures"):
            require(isinstance(journey.get(field), list) and len(journey[field]) >= 3 and
                    all(isinstance(item, str) and item.strip() for item in journey[field]), f"missing journey {field}")
        require(journey.get("milestone") in {f"M{i}" for i in range(1, 6)}, "invalid journey wave")
        require(all(by_id[key]["milestone"] <= journey["milestone"] for key in journey["labs"]),
                f"{journey['id']}: prerequisite later than journey wave")


def outputs(labs: list[dict], journeys: list[dict]) -> dict[str, str]:
    result = {}
    graph = ticket_graph(labs)
    for lab in labs:
        key = lab["id"]
        if int(key[-3:]) > 6:
            result[f"experiments/{key}.md"] = f"# {key}: {lab['title']}\n\nState: specified. No expanded runtime evidence.\n\n" + expansion(lab)
        else:
            result[f"experiments/{key}-EXPANSION.md"] = f"# {key}: {lab['title']} deepening\n\nExisting bounded proof: [{key}]({key}.md), [BUILD_STATUS](../docs/BUILD_STATUS.md).\n\n" + expansion(lab)
        acceptance = lab["deepening_requirements"] if int(key[-3:]) <= 6 else lab["acceptance"]
        for phase in ("A", "B"):
            ticket = key + "-" + phase
            work = "Implementation/deepening" if phase == "A" else "Qualification"
            deps = ", ".join(f"[{dep}]({dep}.md)" for dep in graph[ticket])
            page = key + ("-EXPANSION" if int(key[-3:]) <= 6 else "")
            checks = (acceptance + ["Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene",
                        "Resolve exact installed API signatures and per-operation schemas; preserve existing default build"]
                      if phase == "A" else
                      ([f"Qualify separate new depth: {item}" for item in lab["deepening_requirements"]] +
                       ["Define and run a depth-specific positive assertion and disabled/broken-path negative control for each new requirement; historical seals are regression only"]
                       if int(key[-3:]) <= 6 else []) + lab["acceptance"] + lab["failures"] +
                      ["Run repeated lifecycle/reset and minimal extraction host", "Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates"])
            result[f"tickets/{ticket}.md"] = f"""# {ticket}: {lab['title']} - {work}

State: specified. Planned wave: {'M1 baseline deepening' if int(key[-3:]) <= 6 else lab['milestone']} ({'separate depth, not historical completion' if int(key[-3:]) <= 6 else 'future lab'}).
Depends on: {deps}.

Contract: [{key}](../experiments/{page}.md). Payoff: {lab['payoff']}

## Acceptance

{bullets(checks)}

Required evidence: {', '.join(lab['evidence'])}. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
"""
    for key, title, deps, purpose, checks in CORE:
        result[f"tickets/{key}.md"] = f"""# {key}: {title}

State: {'Done: planning-source verified only' if key == 'CORE-017' else 'specified'}.
Depends on: {', '.join(f'[{dep}]({dep}.md)' for dep in deps)}.

{purpose}

## Acceptance

{bullets(checks)}

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
"""
    counts = Counter(lab["wing"] for lab in labs)
    waves = Counter(lab["milestone"] for lab in labs)
    matrix = ["# Capability matrix", "", "Generated from planning/catalog.json by scripts/plan.py. 96 laboratory contracts; six bounded baseline routes and 90 specified future labs. First-six depth is separately specified. API leads require installed-engine probes.", "", "## Coverage", "", "| Wing | Labs |", "|---|---|"]
    matrix += [f"| {wing} | {counts[wing]} |" for wing in WINGS]
    matrix += ["", "| Wave | Lab assignments |", "|---|---|"] + [f"| M{i} | {waves[f'M{i}']} |" for i in range(6)]
    matrix += ["", "## Contracts", "", "| Lab | Wing / wave | Mechanisms | Required evidence | Lab prerequisites |", "|---|---|---|---|---|"]
    for lab in labs:
        matrix.append(f"| [{lab['id']}: {lab['title']}](../experiments/{lab['id']}.md) | {lab['wing']} / {lab['milestone']} | {'; '.join(lab['mechanism']).replace('|', '/')} | {', '.join(lab['evidence'])} | {', '.join(lab['depends_on']) or 'None'} |")
    result["docs/CAPABILITY_MATRIX.md"] = "\n".join(matrix) + "\n"
    roadmap = ["# Dependency-ordered program", "", "Generated from planning/catalog.json and shared-system gates in scripts/plan.py. **17 shared-system tickets + 192 lab implementation/qualification tickets.** Existing baseline tickets remain historical. CORE-017 qualifies this planning source only; all lab deepening/new runtime work is specified.", "", "Implementation order is the ticket DAG, not catalog numerical order. A lab's prerequisites must qualify before its dependent A begins. Early-wave development may deliver narrower useful slices while later shared capabilities remain explicitly unavailable.", "", "## Shared systems", "", "| Ticket | Contract | Prerequisites |", "|---|---|---|"]
    roadmap += [f"| [{key}](../tickets/{key}.md) | {title} | {', '.join(deps)} |" for key, title, deps, _, _ in CORE]
    roadmap += ["", "## Laboratory delivery", "", "| Lab / wave | Implementation | Qualification | A prerequisites |", "|---|---|---|---|"]
    roadmap += [f"| {lab['id']} / {lab['milestone']} | [{lab['id']}-A](../tickets/{lab['id']}-A.md) | [{lab['id']}-B](../tickets/{lab['id']}-B.md) | {', '.join(graph[lab['id']+'-A'])} |" for lab in labs]
    roadmap += ["", "## Dependency-ready layers", "", "RELEASE-001 is the existing qualified prerequisite. Each layer is eligible only after earlier dependencies close; a layer is not a promise to use every machine at once. CORE-017 is already qualified as planning tooling. Runtime/resource/provider jobs require admission and ownership."]
    for i, layer in enumerate(ordered(graph, {"RELEASE-001"}), 1):
        roadmap += ["", f"{i}. {', '.join(layer)}"]
    result["docs/ROADMAP.md"] = "\n".join(roadmap) + "\n"
    lines = ["# Composed public journeys", "", "Generated from planning/journeys.json. Eight specified executable experiences; the existing bootstrap tour is the only current route. These contracts require qualified lab components and real handoffs, not badge aggregation."]
    for journey in journeys:
        lines += ["", f"## {journey['id']}: {journey['title']}", "", f"State: specified. Wave: {journey['milestone']}.", "", journey["goal"], "", "Prerequisites (qualified B tickets): " + ", ".join(f"[{key}](../experiments/{key}.md)" for key in journey["labs"]) + ".", "", "Cross-lab handoff: " + journey["handoff"], "", "### Player sequence", "", *[f"{i}. {step}" for i, step in enumerate(journey["flow"], 1)], "", "### Integrated acceptance", "", bullets(journey["acceptance"]), "", "### Failure and recovery", "", bullets(journey["failures"]), "", "Qualify normal input and the shared automation route through the entire experience, reset mid-route, restart where durability is claimed, and record actual source/fixture/profile/capture identity. No physical/human claims without a session."]
    result["docs/JOURNEYS.md"] = "\n".join(lines) + "\n"
    return {path: content.rstrip() + "\n" for path, content in result.items()}


def verify_generated(rendered: dict[str, str], root: Path) -> None:
    drift = [path for path, content in rendered.items()
             if not (root / path).is_file() or (root / path).read_text(encoding="utf-8-sig") != content]
    require(not drift, f"generated drift; run --write: {drift[:8]}")


def verify_depth_qualification(labs: list[dict], rendered: dict[str, str]) -> None:
    for lab in labs[:6]:
        qualification = rendered[f"tickets/{lab['id']}-B.md"]
        require(all(item in qualification for item in lab["deepening_requirements"]),
                f"{lab['id']}: qualification omits new depth")
        require("depth-specific positive assertion" in qualification and "negative control" in qualification,
                f"{lab['id']}: depth needs new observations and broken-path controls")


def links(root: Path) -> int:
    count = 0
    for path in sorted(root.rglob("*.md")):
        if any(part in {".git", ".artifacts", "artifacts", "node_modules", ".local", ".cappy"} for part in path.relative_to(root).parts):
            continue
        for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", path.read_text(encoding="utf-8-sig")):
            if re.match(r"[a-zA-Z][a-zA-Z0-9+.-]*:", target) or target.startswith("#"):
                continue
            file_part = target.split("#", 1)[0].split("?", 1)[0].strip("<>")
            require((path.parent / file_part).exists(), f"dangling link: {path.relative_to(root)} -> {target}")
            count += 1
    return count


def self_test(labs: list[dict], journeys: list[dict]) -> int:
    bad = copy.deepcopy(labs); bad[6]["id"] = "LAB-001"
    checks = [("duplicate ID", bad)]
    bad = copy.deepcopy(labs); bad[6]["depends_on"] = ["LAB-999"]; checks.append(("unknown dependency", bad))
    bad = copy.deepcopy(labs); bad[6]["depends_on"] = ["LAB-008"]; bad[7]["depends_on"] = ["LAB-007"]; checks.append(("cycle", bad))
    bad = copy.deepcopy(labs); bad[6]["status"] = "automated-verified"; checks.append(("runtime inflation", bad))
    bad = copy.deepcopy(labs); bad[0]["scenario"] = "renamed"; checks.append(("baseline drift", bad))
    bad = copy.deepcopy(labs); bad[6]["failures"] = []; checks.append(("missing failures", bad))
    bad = copy.deepcopy(labs); bad[6]["operations"] = ["arbitrary_eval"]; checks.append(("invalid operation", bad))
    bad = copy.deepcopy(labs); bad[20]["title"] = "Unrelated replacement"; checks.append(("legacy identity loss", bad))
    for title, data in checks:
        try:
            validate(data)
        except ValueError:
            pass
        else:
            raise ValueError(f"negative control accepted: {title}")
    broken_journey = copy.deepcopy(journeys); broken_journey[0]["labs"].append("LAB-999")
    try:
        validate_journeys(broken_journey, labs)
    except ValueError:
        pass
    else:
        raise ValueError("negative control accepted: unknown journey prerequisite")
    broken_tickets = outputs(labs, journeys)
    depth = labs[0]["deepening_requirements"][0]
    key = "tickets/LAB-001-B.md"
    broken_tickets[key] = broken_tickets[key].replace(depth, "omitted")
    try:
        verify_depth_qualification(labs, broken_tickets)
    except ValueError:
        pass
    else:
        raise ValueError("negative control accepted: missing depth qualification")
    import tempfile
    with tempfile.TemporaryDirectory(prefix="godot-lab-plan-") as folder:
        root = Path(folder)
        root.joinpath("fixture.md").write_text("changed\n", encoding="utf-8")
        for title, action in (("generated drift", lambda: verify_generated({"fixture.md": "expected\n"}, root)),):
            try:
                action()
            except ValueError:
                pass
            else:
                raise ValueError(f"negative control accepted: {title}")
        root.joinpath("fixture.md").write_text("[bad](missing.md)\n", encoding="utf-8")
        try:
            links(root)
        except ValueError:
            pass
        else:
            raise ValueError("negative control accepted: dangling link")
    return len(checks) + 4


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="generate specified documents; never runtime registration")
    parser.add_argument("--check", action="store_true", help="validate catalog, dependency graphs, generated drift and local links")
    parser.add_argument("--self-test", action="store_true", help="prove deliberate broken planning fixtures are rejected")
    args = parser.parse_args()
    labs = json.loads((ROOT / "planning/catalog.json").read_text(encoding="utf-8-sig"))
    journeys = json.loads((ROOT / "planning/journeys.json").read_text(encoding="utf-8-sig"))
    validate(labs)
    validate_journeys(journeys, labs)
    rendered = outputs(labs, journeys)
    verify_depth_qualification(labs, rendered)
    if args.write:
        for name, content in rendered.items():
            target = ROOT / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(content, encoding="utf-8")
    verify_generated(rendered, ROOT)
    local_links = links(ROOT)
    negatives = self_test(labs, journeys) if args.self_test else 0
    print(json.dumps({"result": "passed", "labs": len(labs), "wings": len(WINGS),
                      "shared_system_tickets": len(CORE), "lab_tickets": len(labs)*2,
                      "public_journeys": len(journeys),
                      "generated_documents": len(rendered), "dependency_layers": len(ordered(ticket_graph(labs), {"RELEASE-001"})),
                      "local_links": local_links, "negative_controls": negatives,
                      "runtime_claim": "six bounded bootstrap routes only", "runtime_verified_commit": BASELINE_COMMIT}))


if __name__ == "__main__":
    main()
