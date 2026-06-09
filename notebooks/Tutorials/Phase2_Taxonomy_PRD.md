# PRD — EXAI-KG Phase 2 Node/Edge Taxonomy DRAFT

---

## Problem

Phase 2 turns the OMOP synthetic dataset into a *dynamic clinical knowledge graph*. Before anyone writes
graph-builder code, we need an agreed-upon **taxonomy**: what becomes a node, what becomes an edge, and
which edges form the time backbone the topology metrics (entropy, branching, motif, centrality) run on.
Without this, Abem's edge-list generator and my metric functions could be built against different
assumptions and won't line up.

## Why this matters / what's new here

Currently, two source papers anchor this work, but neither is a drop-in:

- **Panagiotakis et al.** ("Unlocking Healthcare Insights") — Synthea → Neo4j. Gives the concrete
  table→node / join→edge recipe and battle-tested modeling rules. But their graph is **static** (one
  snapshot of all patients).
- **Xiao et al.** ("FHIR-Ontop-OMOP", a Mayo Clinic paper) — maps 11 OMOP tables to a semantic
  (RDF) knowledge graph and frames it explicitly as the substrate for explainable AI. Useful for the
  semantic layer; heavier than we need for the CPU phase.

**The EXAI-KG twist:** our thesis (manuscript RQ1–RQ2) is that *topology changing over time* is the
explainability signal. So our taxonomy must designate a **temporal backbone** — the ordered chain of a
single patient's encounters/events — because that's the structure we snapshot and measure. That temporal
dimension is the part we're adding on top of those papers.

## Success criteria

A taxonomy document that:
1. Lists every node type with its OMOP source table and key properties.
2. Lists every edge type with direction and source (which OMOP join it comes from).
3. Marks which edges are **temporal** (the backbone) vs **descriptive**.
4. States, for each topology metric in Phase 2, which nodes/edges it operates on — so my metric code and
   Abem's builder share one contract.
5. Is concrete enough that Abem can start the edge-list generator from it without guessing.

## Scope

**In:** node + edge types derived from the OMOP tables the pipeline already produces — person,
visit_occurrence, condition_occurrence, drug_exposure, procedure_occurrence, measurement, observation,
plus shared vocabulary Concept nodes. Property-graph model (NetworkX-compatible), per the timeline.

**Out (v1):** AI-suggestion / clinician-action nodes from the grant schema (no model exists yet in the CPU
phase — these come later). RDF/FHIR semantic layer (Xiao-style) — note as a future option, don't build it
now. Provider/care_site nodes — propose deferring unless the team wants referral analysis early.

## Proposed taxonomy (draft)

**Node types**

| Node | OMOP source | Notes |
|---|---|---|
| Patient | person | one per patient; demographics as properties |
| Encounter | visit_occurrence | the temporal anchor; has start/end timestamps |
| Condition | condition_occurrence → Concept | event node, links to shared Concept |
| Drug | drug_exposure → Concept | event node |
| Procedure | procedure_occurrence → Concept | event node; **gaps here if CPT4 unmapped** |
| Measurement | measurement | labs/vitals; value + timestamp |
| Observation | observation | other clinical facts |
| Concept | concept (vocab) | **shared** node (SNOMED/LOINC/RxNorm) — Panagiotakis-style normalization so many patients point to one Condition concept |

**Edge types**

| Edge | From → To | Type |
|---|---|---|
| HAS_ENCOUNTER | Patient → Encounter | structural |
| NEXT_ENCOUNTER | Encounter → Encounter | **temporal backbone** |
| HAS_FIRST / HAS_LAST_ENCOUNTER | Patient → Encounter | temporal anchor |
| RECORDS_CONDITION | Encounter → Condition | descriptive |
| ADMINISTERED | Encounter → Drug | descriptive |
| PERFORMED | Encounter → Procedure | descriptive |
| MEASURED | Encounter → Measurement | descriptive |
| OBSERVED | Encounter → Observation | descriptive |
| MAPS_TO | Condition/Drug/Procedure → Concept | semantic / normalization |

The **NEXT_ENCOUNTER chain + event timestamps** is what we slice into snapshots; topology metrics run on
each snapshot to produce the entropy-over-time, branching, and centrality-shift series.

## Constraints

- Property graph (NetworkX), CPU-only — matches Phase 2 plan and GPU→cuGraph translation later.
- Follow Panagiotakis modeling rules: high-cardinality → nodes, low-cardinality → properties; <~10
  properties/node; avoid `is_a`/`type_of` edges; avoid high-density nodes (path explosion).
- Build from the OMOP tables already in `main`; don't require re-running the ETL.

## Open questions for the team 

1. **Granularity** — one node per raw event (high fidelity, denser graph) vs aggregated patient-state
   nodes? This is the biggest modeling fork and directly changes what entropy/branching even measure.
2. **Snapshot definition** — what is a "timestep"? Per encounter? Per fixed time window (e.g. weekly)?
   Entropy-over-time is undefined until we pick this.
3. **Property graph now, RDF later?** — confirm we stay NetworkX for the CPU phase and treat Xiao-style
   FHIR-RDF as an optional later semantic layer.
4. **CPT4/UMLS** — unmapped procedures = missing Procedure→Concept edges = holes in the topology.
   *Verified 2026-06-08: the current Synthea OMOP export has **0 unmapped events** across all tables, so
   this is a forward risk on real-world data, not a present defect.* My recommendation: skip CPT4 for the
   synthetic prototype, but apply for the UMLS license now (Andy offered) since approval is slow and the VA
   real-world data will need it.
5. **Provider/care_site nodes** — model now for referral/bridge analysis, or defer to keep v1 lean?

## Plan (after sign-off)

1. Lock node/edge tables from feedback above.
2. Expand each into the full taxonomy doc: properties per node, the metric→structure contract, a small
   worked example for one synthetic patient.
3. Hand to Abem as the spec for the edge-list generator.
