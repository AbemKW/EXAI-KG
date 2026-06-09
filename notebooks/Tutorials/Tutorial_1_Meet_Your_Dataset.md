# Tutorial 1 — Meet Your Dataset

*EXAI-KG hands-on series · for new interns · ~45 min*
*Companion to `Intern_Onboarding_Plan.md` (Tier A). Goal: get comfortable opening the real OMOP data, tell **events** apart from **people**, and find the **sepsis cohort** the whole project is built to study.*

By the end you'll be able to answer the Tier A gate questions from memory — because you'll have seen the answers in the data yourself.

---

## Before you start

**What you need**
- A working clone of the `AbemKW_EXAI-KG` repo with the Phase 1 output (the `.parquet` files).
- Python 3 with `pandas` and `pyarrow` (`pip install pandas pyarrow`).
- The three data folders (paths will differ on your machine — set them once below):
  - `data/processed/omop_parquet/` — the 8 OMOP tables (what we mostly use)
  - `data/vocab/` — the vocabulary CSVs, including `CONCEPT.csv`
  - `data/raw/synthea_1000_csv/` — the original Synthea output (we peek at it once)

**One-time setup — edit these paths, then keep this block at the top of every snippet:**

```python
import pandas as pd
from pathlib import Path

OMOP  = Path(r"W:\dev\EXAI-KG-OMOP\EXAI-KG\data\processed\omop_parquet")
VOCAB = Path(r"W:\dev\EXAI-KG-OMOP\EXAI-KG\data\vocab")

def load(table):
    """Load one OMOP table by name."""
    return pd.read_parquet(OMOP / f"{table}.parquet")
```

> **Why Parquet and not CSV?** Parquet is a compact, columnar format built for analytics — it loads far faster than CSV and remembers column types. You'll feel the difference the first time you open `measurement` (575k rows) and it's instant. (We'll come back to *why* columnar matters in a later tutorial.)

---

## Step 1 — The 8 tables, and what each one is

The Phase 1 ETL turned Synthea's output into **8 OMOP tables**. Load them and look at the sizes:

```python
TABLES = ["person","visit_occurrence","condition_occurrence","drug_exposure",
          "procedure_occurrence","measurement","observation","observation_period"]
for t in TABLES:
    print(f"{t:24s} {len(load(t)):>9,}")
```

Expected output:

```
person                       1,174
visit_occurrence            62,999
condition_occurrence        15,976
drug_exposure               70,275
procedure_occurrence       104,078
measurement                575,041
observation                299,276
observation_period           1,174
```

Read that table-by-table — it's the whole shape of a patient's record:

| Table | One row = | Think of it as |
|---|---|---|
| `person` | one patient | the demographics roster |
| `visit_occurrence` | one hospital/clinic visit | the timeline anchor |
| `condition_occurrence` | one diagnosis event | "what's wrong" |
| `drug_exposure` | one drug given/prescribed | "what we gave" |
| `procedure_occurrence` | one procedure done | "what we did" |
| `measurement` | one lab/vital value | "what we measured" |
| `observation` | other clinical facts | the catch-all |
| `observation_period` | one patient's data window | when we have data for them |

**Notice:** `person` and `observation_period` both have **1,174** rows — one per patient. Everything else has *many* rows per patient (events pile up over a lifetime). That gap is the single most important idea in this tutorial — Step 3 makes it concrete.

> **Heads-up:** it's **1,174** patients, not 1,000. Synthea's "1000" run also generates family members, so the real count is higher. Always check, never assume.

---

## Step 2 — Anatomy of the `person` table

```python
person = load("person")
print(person[["person_id","gender_concept_id","year_of_birth","race_concept_id"]].head(3).to_string(index=False))
```

```
 person_id  gender_concept_id  year_of_birth  race_concept_id
         1               8532           2013             8527
         2               8507           1981             8527
         3               8532           2000             8516
```

Two things to absorb here, because they're true of **every** OMOP table:

1. **Almost everything is a number that points somewhere.** `gender_concept_id = 8532` isn't "Female" spelled out — it's a **concept id** that points into the vocabulary. (`8507` = Male, `8532` = Female, in OMOP's standard gender concepts.) This is the project's central trick: *meaning lives in shared Concept ids, not in the row.* You'll use this constantly.
2. **Every `*_concept_id` is a join waiting to happen.** To turn `8532` into the word "Female," you look it up in `CONCEPT.csv`. We do exactly that in Step 4.

> **Try it:** how many men vs women? `person["gender_concept_id"].value_counts()`. Then sanity-check it sums to 1,174.

---

## Step 3 — Events vs. people (the distinction that trips everyone)

This is the Tier A gate's favorite trap. Run it:

```python
co = load("condition_occurrence")
print("people (person rows)            :", len(person))
print("condition rows                  :", len(co))
print("distinct patients w/ a condition:", co["person_id"].nunique())
```

```
people (person rows)            : 1174
condition rows                  : 15976
distinct patients w/ a condition: 1156
```

Sit with these three numbers:

- **1,174** people exist.
- **15,976** condition *rows* — but that's **diagnoses, not patients**. One person can have dozens.
- **1,156** distinct patients actually have at least one condition — so **18 patients have no recorded diagnosis** at all.

The classic mistake — the one the gate is checking for — is to run `len(co)` and call it "number of sick patients." It isn't. It's the number of diagnosis *events*. **A diagnosis lives in its own row in `condition_occurrence`, tied back to a person and a visit.** Whenever you count anything in this dataset, ask: *am I counting events or people?* Use `.nunique()` on `person_id` when you mean people.

---

## Step 4 — Name the top conditions (your first vocabulary join)

Raw concept ids are unreadable. Let's see the most common diagnoses **with their names** by joining to `CONCEPT.csv`.

`CONCEPT.csv` is large (~6.6M rows, ~900 MB), so load only the columns you need — it takes a few seconds, not minutes:

```python
concept = pd.read_csv(VOCAB / "CONCEPT.csv", sep="\t",
                      usecols=["concept_id","concept_name","vocabulary_id","domain_id"])

top = co["condition_concept_id"].value_counts().head(8).rename_axis("concept_id").reset_index(name="n")
top = top.merge(concept, on="concept_id", how="left")
print(top[["concept_id","n","concept_name","vocabulary_id"]].to_string(index=False))
```

```
 concept_id    n        concept_name vocabulary_id
    4281516 3098           Gingivitis        SNOMED
   40481087 1191      Viral sinusitis        SNOMED
    4090111  931      Gingival disease       SNOMED
   40274283  717  Primary dental caries      SNOMED
    4112343  680  Acute viral pharyngitis    SNOMED
     260139  620        Acute bronchitis      SNOMED
    4217975  453        Normal pregnancy      SNOMED
   37018196  404           Prediabetes        SNOMED
```

Three takeaways:

1. **The vocabulary join is how raw data becomes readable.** `4281516` → "Gingivitis." You just did entity resolution by hand — Tutorial 3 makes this a habit.
2. **Conditions map to SNOMED** (the `vocabulary_id` column). Labs will be LOINC, drugs RxNorm — different domains, different vocabularies. Lock that in now.
3. **This is synthetic data, and it shows.** The top diagnoses are dental and minor-respiratory — Synthea's modules skew toward common primary-care stuff. Real EHR data looks different. Good to internalize so you don't over-read patterns that are really just Synthea's generators.

---

## Step 5 — Find the sepsis cohort (the reason this project exists)

The whole EXAI-KG thesis rides on **sepsis** — that's the Synthea module the team modified to inject the overload perturbation. Find those patients.

Sepsis is SNOMED `91302008`, which maps to OMOP standard concept **132797**. Filter on the standard concept id (the right OMOP way — it catches the diagnosis no matter what source code produced it):

```python
sepsis = co[co["condition_concept_id"] == 132797]
print("sepsis condition rows:", len(sepsis))
print("distinct sepsis patients:", sepsis["person_id"].nunique())
```

```
sepsis condition rows: 33
distinct sepsis patients: 33
```

**33 patients.** That's your perturbation cohort — small, so treat it as a set of worked examples, not a dataset for statistics. Note what you just did: you found a clinical cohort by its **standard concept id**, not by searching for the word "sepsis." There's no "sepsis" text anywhere in the OMOP tables — only codes. *Codes are the language of this data.* (If you'd searched the raw Synthea CSV instead, you'd find the text "Sepsis (disorder)" — but the moment data becomes OMOP, you work in concept ids.)

> **Try it:** pick one sepsis patient — `sepsis["person_id"].tolist()` — and count their visits in `visit_occurrence`. You're about to follow one of them through their whole record in Tutorial 2 (we'll use **person_id 403**: 94 visits, 14 conditions — a rich, sepsis-positive example).

---

## Sidebar — a thing that's *not* true here (and why it matters later)

The project's primers warn about "holes" in the data: unmapped codes that resolve to `concept_id = 0` (OMOP's "no matching concept"), especially from procedures needing the CPT4/UMLS vocabulary. **Check whether this dataset actually has any:**

```python
for t, col in [("condition_occurrence","condition_concept_id"),
               ("procedure_occurrence","procedure_concept_id"),
               ("drug_exposure","drug_concept_id"),
               ("measurement","measurement_concept_id"),
               ("observation","observation_concept_id")]:
    df = load(t); z = (df[col] == 0).sum()
    print(f"{t:24s} unmapped: {z:,} / {len(df):,}")
```

You'll find **zero unmapped concepts across all five tables** — everything maps. So the "holes" problem is **not present in this synthetic export**; it's a *future* risk that will appear on real-world data (e.g. the VA dataset) where procedure coding needs CPT4/UMLS. Worth knowing precisely, because it's easy to repeat the warning as if it were visible here — and it isn't. (Tutorial 3 digs into why the gap appears on real data.)

---

## Checkpoint — you can now answer the Tier A gate

Without looking anything up, you should be able to say:

1. **Where does a diabetes diagnosis live, and what does it point to?** → a row in `condition_occurrence`, whose `condition_concept_id` points to a shared **SNOMED** Concept. (You named conditions this way in Step 4; "Prediabetes" was even in your top-8.)
2. **Events vs. people?** → events (conditions, drugs, labs) get their own rows and pile up many-per-patient; only `person`/`observation_period` are one-per-patient. (Step 3.)
3. **What's the sepsis cohort and why does it matter?** → 33 patients carrying SNOMED 91302008 / concept 132797; it's the module the team perturbed, so it's the signal Phase 2 is built to detect. (Step 5.)

**Next:** *Tutorial 2 — Follow One Patient*, where you trace person_id 403 across all 94 visits and watch a real clinical timeline assemble from these tables.
