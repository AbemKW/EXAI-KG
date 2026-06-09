# EXAI-KG — Plain-English Primer on the Graph Concepts

*A cheat sheet for the June 8 sync. Goal: you can follow and contribute even if Andy or Abem dives into
the technical weeds. Nothing here assumes prior graph theory.*

---

## 1. What a graph actually is

A **graph** is just *things* and the *connections between them*.

- **Node** (a.k.a. vertex) = a thing. A patient, a diagnosis, a drug, a hospital visit.
- **Edge** (a.k.a. relationship) = a connection between two things. "Patient HAS this condition."
  "This visit ADMINISTERED that drug."

That's the whole idea. A graph is a network of nodes joined by edges. When the edges have a direction
(A → B, like "visit → diagnosis") it's a *directed* graph, which is what we're building.

**Why bother, instead of a normal database table?** In a spreadsheet, the relationships between things are
implicit — you reconstruct them with joins every time you ask a question. In a graph, the relationships
*are* the data. "Which conditions tend to co-occur? Which visit is the hub everything connects through?"
are one-hop questions in a graph and painful multi-join queries in a table. (This is exactly the case
Panagiotakis makes — and they show the graph answering those questions in near-constant time.)

## 2. Why a *knowledge* graph for clinical data

A patient's medical history is *naturally* a network: visits lead to diagnoses, diagnoses lead to
medications and procedures, labs get measured along the way. Forcing that into flat tables hides the
shape. A clinical knowledge graph keeps the shape intact. Xiao et al. (the Mayo paper) make the stronger
claim we're building on: that graph is the **substrate for explainable AI** — the structure itself carries
the reasoning, not a score bolted on afterward.

## 3. The one clever move: a *shared* Concept node

Naively, you'd give every patient their own "Type 2 Diabetes" node. With 50,000 patients that's 50,000
diabetes nodes that never connect to each other — useless for finding patterns.

Instead we keep **one** "Type 2 Diabetes" Concept node, and every patient who has it points to that same
node (an edge `MAPS_TO`). Now the graph can answer "who clusters around diabetes?" and "is diabetes a hub
connecting many other conditions?" This is **entity normalization** (Panagiotakis Step 2), and it's what
makes the topology metrics below mean anything. The Concept nodes come from medical vocabularies — SNOMED
for conditions, LOINC for labs, RxNorm for drugs. (This is also *why* the CPT4/UMLS gap matters: unmapped
procedures have no Concept node to point to, so they would leave holes in the network.)

> **Empirical note (verified 2026-06-08):** in the *current* synthetic OMOP export, **0 events are
> unmapped** (`concept_id = 0`) across all five event tables — procedures included. So these holes are a
> **forward risk on real-world data** (e.g. the VA dataset, where procedure coding needs CPT4/UMLS), **not**
> something present in our Synthea data today. State it as a future risk, not a current defect.

## 4. The part that's ours: a *dynamic* (temporal) graph

Both papers build one static snapshot. EXAI-KG's whole bet is different: **watch how the graph changes
over time.**

Picture a single patient's encounters laid out in order — visit 1 → visit 2 → visit 3 (that's the
`NEXT_ENCOUNTER` backbone). At each point in time you can take a **snapshot** of what their graph looks
like so far. Early on it's small and simple. As they get sicker — more diagnoses, more drugs, more
referrals — the snapshot gets bigger and more tangled.

We measure the *shape* of each snapshot and watch how those numbers move. A graph that suddenly branches
and tangles may signal a patient (or a clinician's decision space) heading toward **overload** — and we'd
see it in the structure, before any prediction is made. That's the explainability signal.

> **One honest caveat to raise tomorrow:** "a snapshot" needs a definition — per visit? per week? — and
> "what counts as one node" (every raw event, or a summarized patient-state?) is undecided. The metrics
> below are undefined until the team picks these. Bring them as questions, not answers.

## 5. The four topology metrics — what they actually measure

These are the numbers Phase 2 computes on each snapshot. In plain terms:

**Shannon entropy** — *how varied / unpredictable is the graph?* Low entropy = orderly and repetitive
(same few connection types). High entropy = many different kinds of connections, more disorder. A rising
entropy curve over a patient's trajectory = their clinical picture is getting more complex/chaotic.

**Branching factor** — *how much does the graph fan out?* On average, how many new connections spawn from
each node. High branching = the situation is splitting into many directions at once (lots of parallel
problems or options).

**Motif frequency** — *which small recurring patterns show up?* A motif is a tiny sub-shape (e.g. a 3-node
triangle: visit → condition → drug looping back). Counting which little patterns recur tells you the
"building blocks" of a patient's care. Certain motifs may be signatures of certain clinical situations.

**Centrality (and centrality shift)** — *which node is the hub?* Centrality scores how important/connected
each node is. The *shift* is how the hub moves over time — e.g. when one condition suddenly becomes the
center everything else connects through. That hand-off is often the clinically interesting moment.

## 6. Cheat-sheet translations (so jargon doesn't trip you)

| You hear… | It means… |
|---|---|
| node / vertex / entity | a thing (patient, condition, drug) |
| edge / relationship | a connection between two things |
| directed graph | edges have a direction (A → B) |
| property graph | nodes/edges carry attributes; what NetworkX/Neo4j use |
| entity normalization | collapsing duplicates into one shared node |
| snapshot | the graph frozen at one point in time |
| topology | the *shape* of the network |
| NetworkX | the CPU Python library we use (GPU version later = cuGraph) |

## 7. Three things you can say tomorrow and be exactly right

1. "I modeled the taxonomy off Panagiotakis for the table→node mapping and Xiao for the OMOP semantic
   layer, but added a temporal backbone since our thesis is topology *over time*."
2. "Before we build, we need to lock two things: the snapshot interval and event granularity — the metrics
   are undefined without them."
3. "On CPT4: I'd skip it for the synthetic prototype but apply for the UMLS license now, since approval is
   slow and the VA real-world data will need it."
