# Tutorial 2 — Follow One Patient

*EXAI-KG hands-on series · for new interns*

*Goal: assemble one patient's entire medical history out of the scattered OMOP tables, see the **`NEXT_ENCOUNTER` time backbone** with your own eyes, and watch the **sepsis moment** appear in the middle of a real life story.*

Tutorial 1 gave you the bird's-eye view of all 1,174 patients. Now we go deep on exactly one — **person_id 403** — because the knowledge graph you'll build in Tutorial 4 is, at its core, *one patient's timeline turned into nodes and edges*. You can't model a trajectory you haven't read.

**Setup:** same header block as Tutorial 1 (`OMOP`, `VOCAB`, `load()`). Keep it at the top of every snippet.

```python
import pandas as pd
from pathlib import Path
OMOP  = Path(r"W:\dev\EXAI-KG-OMOP\EXAI-KG\data\processed\omop_parquet")
VOCAB = Path(r"W:\dev\EXAI-KG-OMOP\EXAI-KG\data\vocab")
def load(t): return pd.read_parquet(OMOP / f"{t}.parquet")
PID = 403
```

---

## Step 1 — Meet patient 403

A person is just one row in `person` — and, as you learned last time, almost every field is a **concept id pointing into the vocabulary**. Let's pull the row and decode it:

```python
person  = load("person")
concept = pd.read_csv(VOCAB / "CONCEPT.csv", sep="\t", usecols=["concept_id","concept_name"])
look = dict(zip(concept.concept_id, concept.concept_name))   # id -> name lookup

p = person[person.person_id == PID].iloc[0]
print("gender :", look.get(p.gender_concept_id))
print("born   :", p.year_of_birth)
print("race   :", look.get(p.race_concept_id))
```

```
gender : FEMALE
born   : 1951
race   : Asian
```

So 403 is a woman born in 1951. That `look` dictionary — id → name — is the workhorse of this whole tutorial; we built it once and reuse it everywhere. (This *is* the vocabulary join from Tutorial 1, just kept in memory for convenience.)

---

## Step 2 — Her visits, and the time backbone

Everything that happens to a patient hangs off a **visit**. Pull 403's visits in time order:

```python
vo = load("visit_occurrence")
v = vo[vo.person_id == PID].sort_values("visit_start_datetime")
print("total visits:", len(v))
print("span:", v.visit_start_datetime.min().date(), "->", v.visit_start_datetime.max().date())
print(v[["visit_occurrence_id","visit_start_datetime","preceding_visit_occurrence_id"]].head(5).to_string(index=False))
```

```
total visits: 94
span: 1964-09-04 -> 2026-01-09
 visit_occurrence_id visit_start_datetime  preceding_visit_occurrence_id
               22998           1964-09-04                            NaN
               23047           1969-10-03                        22998.0
               23008           1974-08-05                        23047.0
               23039           1982-10-22                        23008.0
               23036           1988-10-28                        23039.0
```

Look at the **`preceding_visit_occurrence_id`** column — this is the project's **`NEXT_ENCOUNTER` backbone** sitting right there in the raw OMOP data. Each visit points back to the one before it: `22998 → 23047 → 23008 → ...`. That chain is the spine Phase 2 slices into snapshots to measure how a patient's graph changes over time.

Two things to notice:

- The **first visit (1964) has `NaN`** — nothing precedes it. That's not a bug; it's the start of the chain (the taxonomy calls it `HAS_FIRST_ENCOUNTER`).
- `93 of 94` visits have a preceding link. The chain is essentially intact, which is why Tutorial 4 can build the backbone straight from this column instead of re-sorting by date.

> **Try it:** confirm the chain is unbroken — `v.preceding_visit_occurrence_id.notna().sum()` should be 93.

---

## Step 3 — Her conditions, as a life story

Now the payoff of going deep. Pull every diagnosis 403 ever got, name it, and read it in order:

```python
co = load("condition_occurrence")
c = co[co.person_id == PID].copy()
c["name"] = c.condition_concept_id.map(look)
print(c[["condition_start_datetime","condition_concept_id","name"]]
        .sort_values("condition_start_datetime").to_string(index=False))
```

```
condition_start_datetime  condition_concept_id                          name
              1982-10-22              37018196                   Prediabetes
              2000-02-27                132797                        Sepsis
              2010-04-20              43530652  Chronic intractable migraine without aura
              2017-08-05               4112853             Malignant tumor of breast
              2017-08-25              40481087               Viral sinusitis
              2019-07-19               4281516                   Gingivitis
              2019-07-26              40481087               Viral sinusitis
              2019-08-02               4090111              Gingival disease
              2019-12-06               4090111              Gingival disease
              2019-12-11                381316      Cerebrovascular accident
              2023-12-15               4281516                   Gingivitis
              2025-07-21                260139              Acute bronchitis
              2025-08-22              40481087               Viral sinusitis
              2025-12-26               4281516                   Gingivitis
```

Read top to bottom and a human life appears: **prediabetes** at 31, **sepsis** at 49, **breast cancer** at 66, a **stroke** (cerebrovascular accident) at 68, with recurring minor stuff (sinusitis, gingivitis) throughout. This is what "a clinical knowledge graph keeps the shape intact" actually means — these 14 rows aren't a bag of codes, they're a trajectory. That trajectory is the thing the project claims to make explainable.

> Notice the data is **internally coherent**: Synthea doesn't sprinkle diagnoses randomly. Watch what happens around the stroke in Step 5.

---

## Step 4 — The sepsis moment, in context

Sepsis is *the* event for this project. Find it, then find the visit it belongs to and see what else was happening:

```python
sep = c[c.condition_concept_id == 132797].iloc[0]
vid = sep.visit_occurrence_id
print("sepsis dx:", sep.condition_start_datetime.date(), "| visit:", int(vid))

de, me = load("drug_exposure"), load("measurement")
n_drug = ((de.person_id==PID) & (de.visit_occurrence_id==vid)).sum()
n_meas = ((me.person_id==PID) & (me.visit_occurrence_id==vid)).sum()
print(f"same visit -> drugs: {n_drug}, measurements: {n_meas}")
```

```
sepsis dx: 2000-02-27 | visit: 22971
same visit -> drugs: 0, measurements: 0
```

Here's an honest surprise worth sitting with: **the sepsis visit has the diagnosis and nothing else** — no drugs, no labs attached to that visit row. You might have expected a flurry of antibiotics and blood cultures. In this synthetic data, they're not linked to that encounter.

Two lessons, both real:

1. **Synthetic data is sparse and imperfect.** Don't assume a clinically "important" event comes with rich surrounding data. When you build the graph, the sepsis node may sit in a thin neighborhood — and your topology metrics will reflect that. Know it before it surprises you.
2. **`visit_occurrence_id` is the glue.** Everything you attach to an encounter, you attach through that id. An event with a different (or null) visit id won't show up here even if it happened "around" the same time. *The links are only as good as the foreign keys.*

> **Try it:** widen the lens — list *all* of 403's events in the year 2000 by date (ignore visit id) and see whether anything sepsis-related is hiding under a different encounter.

---

## Step 5 — Assemble the timeline: how busy was each visit?

A patient's record isn't evenly dense. Some visits are packed; most are nearly empty. Count the events hanging off each of 403's visits:

```python
def per_visit(df): return df[df.person_id==PID].groupby("visit_occurrence_id").size()
load_df = pd.DataFrame({"conditions": per_visit(co),
                        "drugs":      per_visit(de),
                        "measurements": per_visit(me)}).fillna(0).astype(int)
load_df["total"] = load_df.sum(axis=1)
print("busiest 3 visits:")
print(load_df.sort_values("total", ascending=False).head(3).to_string())
print("\nvisits with ZERO events:", (load_df.reindex(v.visit_occurrence_id).fillna(0).total == 0).sum(), "of 94")
```

```
busiest 3 visits:
                     conditions  drugs  measurements  total
visit_occurrence_id
22995                         1      1            32     34
23030                         0      1            32     33
23058                         0      2            26     28

visits with ZERO events: 61 of 94
```

**61 of 94 visits are empty** — just an encounter record with nothing attached. The busy ones are dominated by **measurements** (32 labs in a single checkup). This uneven density is exactly what the topology metrics (branching, entropy) will pick up: a quiet patient produces a sparse, orderly graph; a sick one produces a dense, tangled one.

And the coherence promised in Step 3 — check the stroke:

```python
d = de[de.person_id==PID].copy(); d["name"] = d.drug_concept_id.map(look)
print(d[d.drug_exposure_start_datetime=="2019-12-11"][["drug_exposure_start_datetime","name"]].to_string(index=False))
```

```
drug_exposure_start_datetime                       name
                  2019-12-11  clopidogrel 75 MG Oral Tablet
```

On **2019-12-11**, 403 is diagnosed with a **cerebrovascular accident** (Step 3) *and* started on **clopidogrel** — an antiplatelet drug given exactly for stroke. Same day, clinically correct. (Similarly, her **acute bronchitis** on 2025-07-21 comes with acetaminophen.) Synthea's modules encode real medical logic, which is why these graphs are worth studying at all.

---

## Checkpoint — what you can now do

- **Reconstruct one patient end-to-end** from `person` → `visit_occurrence` → conditions/drugs/measurements, decoding concept ids as you go.
- **Point to the `NEXT_ENCOUNTER` backbone** in real data (`preceding_visit_occurrence_id`) and explain why the first visit is null.
- **Read a trajectory, not just codes** — and stay honest that the data is sparse (the empty sepsis visit) and synthetic-but-coherent (stroke → clopidogrel).

You've now seen, by hand, every ingredient of the graph: **nodes** (the patient, her visits, her conditions/drugs/labs → shared concepts) and **edges** (visit → diagnosis, visit → drug, visit → next visit). 

**Next:** *Tutorial 3 — Codes to Concepts* makes the vocabulary join a real skill (and shows why the CPT4/UMLS gap bites on real data). Then *Tutorial 4 — Build a Tiny Graph* turns this exact patient into nodes and edges with NetworkX.
