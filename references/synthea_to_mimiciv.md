# Synthea → MIMIC-IV schema mapping (draft)

Generated from the cohort in `data/raw/synthea/fhir/` by `notebooks/P1_Wk1_schema_mapping.ipynb` § 2.

**Status:** DRAFT — review pre-filled rows; fill blank `proposed MIMIC-IV target` cells; flag fields that should be dropped.

Two distinct mapping problems to solve:

1. **Structural** — FHIR resource/field → MIMIC-IV table/column (this document).
2. **Vocabulary** — SNOMED-CT / LOINC / RxNorm → ICD-9/10 / itemid / GSN/NDC. Out of scope for this draft; needs separate concept-normalization work.

Cohort scanned: 1,644,276 resources across 20 resource types.

## 1. Resource type → MIMIC-IV table

| Resource type | N | Proposed MIMIC-IV table |
|---|---|---|
| Observation | 662,643 | `mimiciv_hosp.labevents` / `mimiciv_icu.chartevents` (split by category; LOINC → itemid) |
| Procedure | 200,872 | `mimiciv_hosp.procedures_icd` / `mimiciv_icu.procedureevents` (SNOMED-CT → ICD-10-PCS) |
| DiagnosticReport | 146,525 | `mimiciv_hosp.labevents` (aggregated lab panels) |
| Claim | 134,470 | *(out of scope — billing data not in MIMIC core)* |
| ExplanationOfBenefit | 134,470 | *(out of scope — billing data not in MIMIC core)* |
| Encounter | 71,330 | `mimiciv_hosp.admissions` (+ `mimiciv_icu.icustays` for ICU) |
| DocumentReference | 71,330 | MIMIC-IV-Note (`discharge`, `radiology`) — separate dataset |
| MedicationRequest | 63,140 | `mimiciv_hosp.prescriptions` (RxNorm → GSN/NDC) |
| Condition | 44,368 | `mimiciv_hosp.diagnoses_icd` (SNOMED-CT → ICD-10 mapping required) |
| SupplyDelivery | 30,355 | *(no direct MIMIC-IV table)* |
| Medication | 21,743 | `mimiciv_hosp.prescriptions` (referenced by MedicationRequest; flatten on ingest) |
| MedicationAdministration | 21,743 | `mimiciv_icu.inputevents` (RxNorm → GSN/NDC) |
| Immunization | 16,998 | *(no direct MIMIC-IV table)* |
| Device | 6,837 | `mimiciv_icu.inputevents` (device-related) |
| ImagingStudy | 6,093 | *(out of scope — see MIMIC-CXR)* |
| CareTeam | 3,931 | *(no direct MIMIC-IV table — providers folded into `caregiver`)* |
| CarePlan | 3,931 | *(no direct MIMIC-IV table)* |
| Patient | 1,178 | `mimiciv_hosp.patients` |
| Provenance | 1,178 | *(FHIR metadata — not mapped)* |
| AllergyIntolerance | 1,141 | *(no direct MIMIC-IV table)* |

## 2. Field-level mappings

Each section below lists every JSON path that appears in at least one resource of that type, sorted by frequency. `pct` is the share of resources of that type containing the path.

### Observation (662,643 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `category` |  |  |
| 100.0% | `category[].coding` |  |  |
| 100.0% | `category[].coding[].code` |  |  |
| 100.0% | `category[].coding[].display` |  |  |
| 100.0% | `category[].coding[].system` |  |  |
| 100.0% | `code` |  |  |
| 100.0% | `code.coding` |  |  |
| 100.0% | `code.coding[].code` |  |  |
| 100.0% | `code.coding[].display` |  |  |
| 100.0% | `code.coding[].system` |  |  |
| 100.0% | `code.text` |  |  |
| 100.0% | `effectiveDateTime` |  |  |
| 100.0% | `encounter` |  |  |
| 100.0% | `encounter.reference` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `issued` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `subject` |  |  |
| 100.0% | `subject.reference` |  |  |
| 93.1% | `meta` |  |  |
| 93.1% | `meta.profile` |  |  |
| 77.7% | `valueQuantity` |  |  |
| 77.7% | `valueQuantity.system` |  |  |
| 77.7% | `valueQuantity.value` |  |  |
| 77.7% | `valueQuantity.code` |  |  |
| 77.7% | `valueQuantity.unit` |  |  |
| 17.7% | `valueCodeableConcept` |  |  |
| 17.7% | `valueCodeableConcept.coding` |  |  |
| 17.7% | `valueCodeableConcept.coding[].code` |  |  |
| 17.7% | `valueCodeableConcept.coding[].display` |  |  |
| 17.7% | `valueCodeableConcept.coding[].system` |  |  |
| 17.7% | `valueCodeableConcept.text` |  |  |
| 4.5% | `component` |  |  |
| 4.5% | `component[].code` |  |  |
| 4.5% | `component[].code.coding` |  |  |
| 4.5% | `component[].code.coding[].code` |  |  |
| 4.5% | `component[].code.coding[].display` |  |  |
| 4.5% | `component[].code.coding[].system` |  |  |
| 4.5% | `component[].code.text` |  |  |
| 4.5% | `component[].valueQuantity` |  |  |
| 4.5% | `component[].valueQuantity.code` |  |  |
| 4.5% | `component[].valueQuantity.system` |  |  |
| 4.5% | `component[].valueQuantity.unit` |  |  |
| 4.5% | `component[].valueQuantity.value` |  |  |
| 1.9% | `component[].valueString` |  |  |
| 1.9% | `component[].valueCodeableConcept` |  |  |
| 1.9% | `component[].valueCodeableConcept.coding` |  |  |
| 1.9% | `component[].valueCodeableConcept.coding[].code` |  |  |
| 1.9% | `component[].valueCodeableConcept.coding[].display` |  |  |
| 1.9% | `component[].valueCodeableConcept.coding[].system` |  |  |
| 1.9% | `component[].valueCodeableConcept.text` |  |  |
| 0.1% | `valueString` |  |  |

### Procedure (200,872 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `code` |  |  |
| 100.0% | `code.coding` |  |  |
| 100.0% | `code.coding[].code` |  |  |
| 100.0% | `code.coding[].display` |  |  |
| 100.0% | `code.coding[].system` |  |  |
| 100.0% | `code.text` |  |  |
| 100.0% | `encounter` |  |  |
| 100.0% | `encounter.reference` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `location` |  |  |
| 100.0% | `location.display` |  |  |
| 100.0% | `location.reference` |  |  |
| 100.0% | `meta` |  |  |
| 100.0% | `meta.profile` |  |  |
| 100.0% | `performedPeriod` |  |  |
| 100.0% | `performedPeriod.end` |  |  |
| 100.0% | `performedPeriod.start` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `subject` |  |  |
| 100.0% | `subject.reference` |  |  |
| 34.5% | `reasonReference` |  |  |
| 34.5% | `reasonReference[].display` |  |  |
| 34.5% | `reasonReference[].reference` |  |  |
| 11.0% | `reasonCode` |  |  |
| 11.0% | `reasonCode[].coding` |  |  |
| 11.0% | `reasonCode[].coding[].code` |  |  |
| 11.0% | `reasonCode[].coding[].display` |  |  |
| 11.0% | `reasonCode[].coding[].system` |  |  |
| 11.0% | `reasonCode[].text` |  |  |

### DiagnosticReport (146,525 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `code` |  |  |
| 100.0% | `code.coding` |  |  |
| 100.0% | `code.coding[].code` |  |  |
| 100.0% | `code.coding[].display` |  |  |
| 100.0% | `code.coding[].system` |  |  |
| 100.0% | `effectiveDateTime` |  |  |
| 100.0% | `encounter` |  |  |
| 100.0% | `encounter.reference` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `issued` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `subject` |  |  |
| 100.0% | `subject.reference` |  |  |
| 77.6% | `category` |  |  |
| 77.6% | `category[].coding` |  |  |
| 77.6% | `category[].coding[].code` |  |  |
| 77.6% | `category[].coding[].display` |  |  |
| 77.6% | `category[].coding[].system` |  |  |
| 77.6% | `meta` |  |  |
| 77.6% | `meta.profile` |  |  |
| 77.6% | `performer` |  |  |
| 77.6% | `performer[].display` |  |  |
| 77.6% | `performer[].reference` |  |  |
| 51.3% | `code.text` |  |  |
| 51.3% | `result` |  |  |
| 51.3% | `result[].display` |  |  |
| 51.3% | `result[].reference` |  |  |
| 48.7% | `presentedForm` |  |  |
| 48.7% | `presentedForm[].contentType` |  |  |
| 48.7% | `presentedForm[].data` |  |  |

### Claim (134,470 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `billablePeriod` |  |  |
| 100.0% | `billablePeriod.end` |  |  |
| 100.0% | `billablePeriod.start` |  |  |
| 100.0% | `created` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `insurance` |  |  |
| 100.0% | `insurance[].coverage` |  |  |
| 100.0% | `insurance[].coverage.display` |  |  |
| 100.0% | `insurance[].focal` |  |  |
| 100.0% | `insurance[].sequence` |  |  |
| 100.0% | `item` |  |  |
| 100.0% | `item[].encounter` |  |  |
| 100.0% | `item[].encounter[].reference` |  |  |
| 100.0% | `item[].productOrService` |  |  |
| 100.0% | `item[].productOrService.coding` |  |  |
| 100.0% | `item[].productOrService.coding[].code` |  |  |
| 100.0% | `item[].productOrService.coding[].display` |  |  |
| 100.0% | `item[].productOrService.coding[].system` |  |  |
| 100.0% | `item[].productOrService.text` |  |  |
| 100.0% | `item[].sequence` |  |  |
| 100.0% | `patient` |  |  |
| 100.0% | `patient.reference` |  |  |
| 100.0% | `priority` |  |  |
| 100.0% | `priority.coding` |  |  |
| 100.0% | `priority.coding[].code` |  |  |
| 100.0% | `priority.coding[].system` |  |  |
| 100.0% | `provider` |  |  |
| 100.0% | `provider.display` |  |  |
| 100.0% | `provider.reference` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `total` |  |  |
| 100.0% | `total.currency` |  |  |
| 100.0% | `total.value` |  |  |
| 100.0% | `type` |  |  |
| 100.0% | `type.coding` |  |  |
| 100.0% | `type.coding[].code` |  |  |
| 100.0% | `type.coding[].system` |  |  |
| 100.0% | `use` |  |  |
| 53.0% | `facility` |  |  |
| 53.0% | `facility.display` |  |  |
| 53.0% | `facility.reference` |  |  |
| 53.0% | `patient.display` |  |  |
| 47.0% | `prescription` |  |  |
| 47.0% | `prescription.reference` |  |  |
| 43.7% | `item[].net` |  |  |
| 43.7% | `item[].net.currency` |  |  |
| 43.7% | `item[].net.value` |  |  |
| 37.9% | `item[].procedureSequence` |  |  |
| 37.9% | `procedure` |  |  |
| 37.9% | `procedure[].procedureReference` |  |  |
| 37.9% | `procedure[].procedureReference.reference` |  |  |
| 37.9% | `procedure[].sequence` |  |  |
| 24.3% | `item[].informationSequence` |  |  |
| 24.3% | `supportingInfo` |  |  |
| 24.3% | `supportingInfo[].category` |  |  |
| 24.3% | `supportingInfo[].category.coding` |  |  |
| 24.3% | `supportingInfo[].category.coding[].code` |  |  |
| 24.3% | `supportingInfo[].category.coding[].system` |  |  |
| 24.3% | `supportingInfo[].sequence` |  |  |
| 21.1% | `diagnosis` |  |  |
| 21.1% | `diagnosis[].diagnosisReference` |  |  |
| 21.1% | `diagnosis[].diagnosisReference.reference` |  |  |
| 21.1% | `diagnosis[].sequence` |  |  |
| 21.1% | `item[].diagnosisSequence` |  |  |
| 8.9% | `supportingInfo[].valueReference` |  |  |
| 8.9% | `supportingInfo[].valueReference.reference` |  |  |

### ExplanationOfBenefit (134,470 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `billablePeriod` |  |  |
| 100.0% | `billablePeriod.end` |  |  |
| 100.0% | `billablePeriod.start` |  |  |
| 100.0% | `careTeam` |  |  |
| 100.0% | `careTeam[].provider` |  |  |
| 100.0% | `careTeam[].provider.reference` |  |  |
| 100.0% | `careTeam[].role` |  |  |
| 100.0% | `careTeam[].role.coding` |  |  |
| 100.0% | `careTeam[].role.coding[].code` |  |  |
| 100.0% | `careTeam[].role.coding[].display` |  |  |
| 100.0% | `careTeam[].role.coding[].system` |  |  |
| 100.0% | `careTeam[].sequence` |  |  |
| 100.0% | `claim` |  |  |
| 100.0% | `claim.reference` |  |  |
| 100.0% | `contained` |  |  |
| 100.0% | `contained[].beneficiary` |  |  |
| 100.0% | `contained[].beneficiary.reference` |  |  |
| 100.0% | `contained[].id` |  |  |
| 100.0% | `contained[].intent` |  |  |
| 100.0% | `contained[].payor` |  |  |
| 100.0% | `contained[].payor[].display` |  |  |
| 100.0% | `contained[].performer` |  |  |
| 100.0% | `contained[].performer[].reference` |  |  |
| 100.0% | `contained[].requester` |  |  |
| 100.0% | `contained[].requester.reference` |  |  |
| 100.0% | `contained[].resourceType` |  |  |
| 100.0% | `contained[].status` |  |  |
| 100.0% | `contained[].subject` |  |  |
| 100.0% | `contained[].subject.reference` |  |  |
| 100.0% | `contained[].type` |  |  |
| 100.0% | `contained[].type.text` |  |  |
| 100.0% | `created` |  |  |
| 100.0% | `facility` |  |  |
| 100.0% | `facility.display` |  |  |
| 100.0% | `facility.reference` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `identifier` |  |  |
| 100.0% | `identifier[].system` |  |  |
| 100.0% | `identifier[].value` |  |  |
| 100.0% | `insurance` |  |  |
| 100.0% | `insurance[].coverage` |  |  |
| 100.0% | `insurance[].coverage.display` |  |  |
| 100.0% | `insurance[].coverage.reference` |  |  |
| 100.0% | `insurance[].focal` |  |  |
| 100.0% | `insurer` |  |  |
| 100.0% | `insurer.display` |  |  |
| 100.0% | `item` |  |  |
| 100.0% | `item[].category` |  |  |
| 100.0% | `item[].category.coding` |  |  |
| 100.0% | `item[].category.coding[].code` |  |  |
| 100.0% | `item[].category.coding[].display` |  |  |
| 100.0% | `item[].category.coding[].system` |  |  |
| 100.0% | `item[].encounter` |  |  |
| 100.0% | `item[].encounter[].reference` |  |  |
| 100.0% | `item[].locationCodeableConcept` |  |  |
| 100.0% | `item[].locationCodeableConcept.coding` |  |  |
| 100.0% | `item[].locationCodeableConcept.coding[].code` |  |  |
| 100.0% | `item[].locationCodeableConcept.coding[].display` |  |  |
| 100.0% | `item[].locationCodeableConcept.coding[].system` |  |  |
| 100.0% | `item[].productOrService` |  |  |
| 100.0% | `item[].productOrService.coding` |  |  |
| 100.0% | `item[].productOrService.coding[].code` |  |  |
| 100.0% | `item[].productOrService.coding[].display` |  |  |
| 100.0% | `item[].productOrService.coding[].system` |  |  |
| 100.0% | `item[].productOrService.text` |  |  |
| 100.0% | `item[].sequence` |  |  |
| 100.0% | `item[].servicedPeriod` |  |  |
| 100.0% | `item[].servicedPeriod.end` |  |  |
| 100.0% | `item[].servicedPeriod.start` |  |  |
| 100.0% | `outcome` |  |  |
| 100.0% | `patient` |  |  |
| 100.0% | `patient.reference` |  |  |
| 100.0% | `payment` |  |  |
| 100.0% | `payment.amount` |  |  |
| 100.0% | `payment.amount.currency` |  |  |
| 100.0% | `payment.amount.value` |  |  |
| 100.0% | `provider` |  |  |
| 100.0% | `provider.reference` |  |  |
| 100.0% | `referral` |  |  |
| 100.0% | `referral.reference` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `total` |  |  |
| 100.0% | `total[].amount` |  |  |
| 100.0% | `total[].amount.currency` |  |  |
| 100.0% | `total[].amount.value` |  |  |
| 100.0% | `total[].category` |  |  |
| 100.0% | `total[].category.coding` |  |  |
| 100.0% | `total[].category.coding[].code` |  |  |
| 100.0% | `total[].category.coding[].display` |  |  |
| 100.0% | `total[].category.coding[].system` |  |  |
| 100.0% | `total[].category.text` |  |  |
| 100.0% | `type` |  |  |
| 100.0% | `type.coding` |  |  |
| 100.0% | `type.coding[].code` |  |  |
| 100.0% | `type.coding[].system` |  |  |
| 100.0% | `use` |  |  |
| 43.7% | `item[].adjudication` |  |  |
| 43.7% | `item[].adjudication[].amount` |  |  |
| 43.7% | `item[].adjudication[].amount.currency` |  |  |
| 43.7% | `item[].adjudication[].amount.value` |  |  |
| 43.7% | `item[].adjudication[].category` |  |  |
| 43.7% | `item[].adjudication[].category.coding` |  |  |
| 43.7% | `item[].adjudication[].category.coding[].code` |  |  |
| 43.7% | `item[].adjudication[].category.coding[].display` |  |  |
| 43.7% | `item[].adjudication[].category.coding[].system` |  |  |
| 43.7% | `item[].net` |  |  |
| 43.7% | `item[].net.currency` |  |  |
| 43.7% | `item[].net.value` |  |  |
| 24.3% | `item[].informationSequence` |  |  |
| 21.1% | `diagnosis` |  |  |
| 21.1% | `diagnosis[].diagnosisReference` |  |  |
| 21.1% | `diagnosis[].diagnosisReference.reference` |  |  |
| 21.1% | `diagnosis[].sequence` |  |  |
| 21.1% | `diagnosis[].type` |  |  |
| 21.1% | `diagnosis[].type[].coding` |  |  |
| 21.1% | `diagnosis[].type[].coding[].code` |  |  |
| 21.1% | `diagnosis[].type[].coding[].system` |  |  |
| 21.1% | `item[].diagnosisSequence` |  |  |

### Encounter (71,330 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `class` |  |  |
| 100.0% | `class.code` |  |  |
| 100.0% | `class.system` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `identifier` |  |  |
| 100.0% | `identifier[].system` |  |  |
| 100.0% | `identifier[].use` |  |  |
| 100.0% | `identifier[].value` |  |  |
| 100.0% | `location` |  |  |
| 100.0% | `location[].location` |  |  |
| 100.0% | `location[].location.display` |  |  |
| 100.0% | `location[].location.reference` |  |  |
| 100.0% | `meta` |  |  |
| 100.0% | `meta.profile` |  |  |
| 100.0% | `participant` |  |  |
| 100.0% | `participant[].individual` |  |  |
| 100.0% | `participant[].individual.display` |  |  |
| 100.0% | `participant[].individual.reference` |  |  |
| 100.0% | `participant[].period` |  |  |
| 100.0% | `participant[].period.end` |  |  |
| 100.0% | `participant[].period.start` |  |  |
| 100.0% | `participant[].type` |  |  |
| 100.0% | `participant[].type[].coding` |  |  |
| 100.0% | `participant[].type[].coding[].code` |  |  |
| 100.0% | `participant[].type[].coding[].display` |  |  |
| 100.0% | `participant[].type[].coding[].system` |  |  |
| 100.0% | `participant[].type[].text` |  |  |
| 100.0% | `period` |  |  |
| 100.0% | `period.end` |  |  |
| 100.0% | `period.start` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `serviceProvider` |  |  |
| 100.0% | `serviceProvider.display` |  |  |
| 100.0% | `serviceProvider.reference` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `subject` |  |  |
| 100.0% | `subject.display` |  |  |
| 100.0% | `subject.reference` |  |  |
| 100.0% | `type` |  |  |
| 100.0% | `type[].coding` |  |  |
| 100.0% | `type[].coding[].code` |  |  |
| 100.0% | `type[].coding[].display` |  |  |
| 100.0% | `type[].coding[].system` |  |  |
| 100.0% | `type[].text` |  |  |
| 62.4% | `reasonCode` |  |  |
| 62.4% | `reasonCode[].coding` |  |  |
| 62.4% | `reasonCode[].coding[].code` |  |  |
| 62.4% | `reasonCode[].coding[].display` |  |  |
| 62.4% | `reasonCode[].coding[].system` |  |  |
| 0.3% | `hospitalization` |  |  |
| 0.3% | `hospitalization.dischargeDisposition` |  |  |
| 0.3% | `hospitalization.dischargeDisposition.coding` |  |  |
| 0.3% | `hospitalization.dischargeDisposition.coding[].code` |  |  |
| 0.3% | `hospitalization.dischargeDisposition.coding[].display` |  |  |
| 0.3% | `hospitalization.dischargeDisposition.coding[].system` |  |  |
| 0.3% | `hospitalization.dischargeDisposition.text` |  |  |

### DocumentReference (71,330 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `author` |  |  |
| 100.0% | `author[].display` |  |  |
| 100.0% | `author[].reference` |  |  |
| 100.0% | `category` |  |  |
| 100.0% | `category[].coding` |  |  |
| 100.0% | `category[].coding[].code` |  |  |
| 100.0% | `category[].coding[].display` |  |  |
| 100.0% | `category[].coding[].system` |  |  |
| 100.0% | `content` |  |  |
| 100.0% | `content[].attachment` |  |  |
| 100.0% | `content[].attachment.contentType` |  |  |
| 100.0% | `content[].attachment.data` |  |  |
| 100.0% | `content[].format` |  |  |
| 100.0% | `content[].format.code` |  |  |
| 100.0% | `content[].format.display` |  |  |
| 100.0% | `content[].format.system` |  |  |
| 100.0% | `context` |  |  |
| 100.0% | `context.encounter` |  |  |
| 100.0% | `context.encounter[].reference` |  |  |
| 100.0% | `context.period` |  |  |
| 100.0% | `context.period.end` |  |  |
| 100.0% | `context.period.start` |  |  |
| 100.0% | `custodian` |  |  |
| 100.0% | `custodian.display` |  |  |
| 100.0% | `custodian.reference` |  |  |
| 100.0% | `date` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `identifier` |  |  |
| 100.0% | `identifier[].system` |  |  |
| 100.0% | `identifier[].value` |  |  |
| 100.0% | `meta` |  |  |
| 100.0% | `meta.profile` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `subject` |  |  |
| 100.0% | `subject.reference` |  |  |
| 100.0% | `type` |  |  |
| 100.0% | `type.coding` |  |  |
| 100.0% | `type.coding[].code` |  |  |
| 100.0% | `type.coding[].display` |  |  |
| 100.0% | `type.coding[].system` |  |  |

### MedicationRequest (63,140 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `authoredOn` |  |  |
| 100.0% | `category` |  |  |
| 100.0% | `category[].coding` |  |  |
| 100.0% | `category[].coding[].code` |  |  |
| 100.0% | `category[].coding[].display` |  |  |
| 100.0% | `category[].coding[].system` |  |  |
| 100.0% | `category[].text` |  |  |
| 100.0% | `encounter` |  |  |
| 100.0% | `encounter.reference` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `intent` |  |  |
| 100.0% | `meta` |  |  |
| 100.0% | `meta.profile` |  |  |
| 100.0% | `requester` |  |  |
| 100.0% | `requester.display` |  |  |
| 100.0% | `requester.reference` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `subject` |  |  |
| 100.0% | `subject.reference` |  |  |
| 73.4% | `reasonReference` |  |  |
| 73.4% | `reasonReference[].display` |  |  |
| 73.4% | `reasonReference[].reference` |  |  |
| 65.6% | `medicationCodeableConcept` |  |  |
| 65.6% | `medicationCodeableConcept.coding` |  |  |
| 65.6% | `medicationCodeableConcept.coding[].code` |  |  |
| 65.6% | `medicationCodeableConcept.coding[].display` |  |  |
| 65.6% | `medicationCodeableConcept.coding[].system` |  |  |
| 65.6% | `medicationCodeableConcept.text` |  |  |
| 44.0% | `dosageInstruction` |  |  |
| 44.0% | `dosageInstruction[].asNeededBoolean` |  |  |
| 44.0% | `dosageInstruction[].sequence` |  |  |
| 34.4% | `medicationReference` |  |  |
| 34.4% | `medicationReference.reference` |  |  |
| 31.8% | `dosageInstruction[].doseAndRate` |  |  |
| 31.8% | `dosageInstruction[].doseAndRate[].doseQuantity` |  |  |
| 31.8% | `dosageInstruction[].doseAndRate[].doseQuantity.value` |  |  |
| 31.8% | `dosageInstruction[].doseAndRate[].type` |  |  |
| 31.8% | `dosageInstruction[].doseAndRate[].type.coding` |  |  |
| 31.8% | `dosageInstruction[].doseAndRate[].type.coding[].code` |  |  |
| 31.8% | `dosageInstruction[].doseAndRate[].type.coding[].display` |  |  |
| 31.8% | `dosageInstruction[].doseAndRate[].type.coding[].system` |  |  |
| 31.8% | `dosageInstruction[].timing` |  |  |
| 31.8% | `dosageInstruction[].timing.repeat` |  |  |
| 31.8% | `dosageInstruction[].timing.repeat.frequency` |  |  |
| 31.8% | `dosageInstruction[].timing.repeat.period` |  |  |
| 31.8% | `dosageInstruction[].timing.repeat.periodUnit` |  |  |
| 20.1% | `dosageInstruction[].text` |  |  |
| 7.9% | `dosageInstruction[].additionalInstruction` |  |  |
| 7.9% | `dosageInstruction[].additionalInstruction[].coding` |  |  |
| 7.9% | `dosageInstruction[].additionalInstruction[].coding[].code` |  |  |
| 7.9% | `dosageInstruction[].additionalInstruction[].coding[].display` |  |  |
| 7.9% | `dosageInstruction[].additionalInstruction[].coding[].system` |  |  |
| 7.9% | `dosageInstruction[].additionalInstruction[].text` |  |  |
| 7.4% | `reasonCode` |  |  |
| 7.4% | `reasonCode[].coding` |  |  |
| 7.4% | `reasonCode[].coding[].code` |  |  |
| 7.4% | `reasonCode[].coding[].display` |  |  |
| 7.4% | `reasonCode[].coding[].system` |  |  |
| 7.4% | `reasonCode[].text` |  |  |

### Condition (44,368 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `category` |  |  |
| 100.0% | `category[].coding` |  |  |
| 100.0% | `category[].coding[].code` |  |  |
| 100.0% | `category[].coding[].display` |  |  |
| 100.0% | `category[].coding[].system` |  |  |
| 100.0% | `clinicalStatus` |  |  |
| 100.0% | `clinicalStatus.coding` |  |  |
| 100.0% | `clinicalStatus.coding[].code` |  |  |
| 100.0% | `clinicalStatus.coding[].system` |  |  |
| 100.0% | `code` |  |  |
| 100.0% | `code.coding` |  |  |
| 100.0% | `code.coding[].code` |  |  |
| 100.0% | `code.coding[].display` |  |  |
| 100.0% | `code.coding[].system` |  |  |
| 100.0% | `code.text` |  |  |
| 100.0% | `encounter` |  |  |
| 100.0% | `encounter.reference` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `meta` |  |  |
| 100.0% | `meta.profile` |  |  |
| 100.0% | `onsetDateTime` |  |  |
| 100.0% | `recordedDate` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `subject` |  |  |
| 100.0% | `subject.reference` |  |  |
| 100.0% | `verificationStatus` |  |  |
| 100.0% | `verificationStatus.coding` |  |  |
| 100.0% | `verificationStatus.coding[].code` |  |  |
| 100.0% | `verificationStatus.coding[].system` |  |  |
| 74.5% | `abatementDateTime` |  |  |

### SupplyDelivery (30,355 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `id` |  |  |
| 100.0% | `occurrenceDateTime` |  |  |
| 100.0% | `patient` |  |  |
| 100.0% | `patient.reference` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `suppliedItem` |  |  |
| 100.0% | `suppliedItem.itemCodeableConcept` |  |  |
| 100.0% | `suppliedItem.itemCodeableConcept.coding` |  |  |
| 100.0% | `suppliedItem.itemCodeableConcept.coding[].code` |  |  |
| 100.0% | `suppliedItem.itemCodeableConcept.coding[].display` |  |  |
| 100.0% | `suppliedItem.itemCodeableConcept.coding[].system` |  |  |
| 100.0% | `suppliedItem.itemCodeableConcept.text` |  |  |
| 100.0% | `suppliedItem.quantity` |  |  |
| 100.0% | `suppliedItem.quantity.value` |  |  |
| 100.0% | `type` |  |  |
| 100.0% | `type.coding` |  |  |
| 100.0% | `type.coding[].code` |  |  |
| 100.0% | `type.coding[].display` |  |  |
| 100.0% | `type.coding[].system` |  |  |

### Medication (21,743 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `code` |  |  |
| 100.0% | `code.coding` |  |  |
| 100.0% | `code.coding[].code` |  |  |
| 100.0% | `code.coding[].display` |  |  |
| 100.0% | `code.coding[].system` |  |  |
| 100.0% | `code.text` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `meta` |  |  |
| 100.0% | `meta.profile` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `status` |  |  |

### MedicationAdministration (21,743 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `context` |  |  |
| 100.0% | `context.reference` |  |  |
| 100.0% | `effectiveDateTime` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `medicationCodeableConcept` |  |  |
| 100.0% | `medicationCodeableConcept.coding` |  |  |
| 100.0% | `medicationCodeableConcept.coding[].code` |  |  |
| 100.0% | `medicationCodeableConcept.coding[].display` |  |  |
| 100.0% | `medicationCodeableConcept.coding[].system` |  |  |
| 100.0% | `medicationCodeableConcept.text` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `subject` |  |  |
| 100.0% | `subject.reference` |  |  |
| 77.8% | `reasonReference` |  |  |
| 77.8% | `reasonReference[].display` |  |  |
| 77.8% | `reasonReference[].reference` |  |  |
| 11.2% | `reasonCode` |  |  |
| 11.2% | `reasonCode[].coding` |  |  |
| 11.2% | `reasonCode[].coding[].code` |  |  |
| 11.2% | `reasonCode[].coding[].display` |  |  |
| 11.2% | `reasonCode[].coding[].system` |  |  |
| 11.2% | `reasonCode[].text` |  |  |
| 1.1% | `dosage` |  |  |
| 1.1% | `dosage.dose` |  |  |
| 1.1% | `dosage.dose.value` |  |  |
| 0.4% | `dosage.rateQuantity` |  |  |
| 0.4% | `dosage.rateQuantity.value` |  |  |

### Immunization (16,998 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `encounter` |  |  |
| 100.0% | `encounter.reference` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `location` |  |  |
| 100.0% | `location.display` |  |  |
| 100.0% | `location.reference` |  |  |
| 100.0% | `meta` |  |  |
| 100.0% | `meta.profile` |  |  |
| 100.0% | `occurrenceDateTime` |  |  |
| 100.0% | `patient` |  |  |
| 100.0% | `patient.reference` |  |  |
| 100.0% | `primarySource` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `vaccineCode` |  |  |
| 100.0% | `vaccineCode.coding` |  |  |
| 100.0% | `vaccineCode.coding[].code` |  |  |
| 100.0% | `vaccineCode.coding[].display` |  |  |
| 100.0% | `vaccineCode.coding[].system` |  |  |
| 100.0% | `vaccineCode.text` |  |  |

### Device (6,837 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `deviceName` |  |  |
| 100.0% | `deviceName[].name` |  |  |
| 100.0% | `deviceName[].type` |  |  |
| 100.0% | `distinctIdentifier` |  |  |
| 100.0% | `expirationDate` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `lotNumber` |  |  |
| 100.0% | `manufactureDate` |  |  |
| 100.0% | `meta` |  |  |
| 100.0% | `meta.profile` |  |  |
| 100.0% | `patient` |  |  |
| 100.0% | `patient.reference` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `serialNumber` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `type` |  |  |
| 100.0% | `type.coding` |  |  |
| 100.0% | `type.coding[].code` |  |  |
| 100.0% | `type.coding[].display` |  |  |
| 100.0% | `type.coding[].system` |  |  |
| 100.0% | `type.text` |  |  |
| 100.0% | `udiCarrier` |  |  |
| 100.0% | `udiCarrier[].carrierHRF` |  |  |
| 100.0% | `udiCarrier[].deviceIdentifier` |  |  |

### ImagingStudy (6,093 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `encounter` |  |  |
| 100.0% | `encounter.reference` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `identifier` |  |  |
| 100.0% | `identifier[].system` |  |  |
| 100.0% | `identifier[].use` |  |  |
| 100.0% | `identifier[].value` |  |  |
| 100.0% | `location` |  |  |
| 100.0% | `location.display` |  |  |
| 100.0% | `location.reference` |  |  |
| 100.0% | `numberOfInstances` |  |  |
| 100.0% | `numberOfSeries` |  |  |
| 100.0% | `procedureCode` |  |  |
| 100.0% | `procedureCode[].coding` |  |  |
| 100.0% | `procedureCode[].coding[].code` |  |  |
| 100.0% | `procedureCode[].coding[].display` |  |  |
| 100.0% | `procedureCode[].coding[].system` |  |  |
| 100.0% | `procedureCode[].text` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `series` |  |  |
| 100.0% | `series[].bodySite` |  |  |
| 100.0% | `series[].bodySite.code` |  |  |
| 100.0% | `series[].bodySite.display` |  |  |
| 100.0% | `series[].bodySite.system` |  |  |
| 100.0% | `series[].instance` |  |  |
| 100.0% | `series[].instance[].number` |  |  |
| 100.0% | `series[].instance[].sopClass` |  |  |
| 100.0% | `series[].instance[].sopClass.code` |  |  |
| 100.0% | `series[].instance[].sopClass.system` |  |  |
| 100.0% | `series[].instance[].title` |  |  |
| 100.0% | `series[].instance[].uid` |  |  |
| 100.0% | `series[].modality` |  |  |
| 100.0% | `series[].modality.code` |  |  |
| 100.0% | `series[].modality.display` |  |  |
| 100.0% | `series[].modality.system` |  |  |
| 100.0% | `series[].number` |  |  |
| 100.0% | `series[].numberOfInstances` |  |  |
| 100.0% | `series[].started` |  |  |
| 100.0% | `series[].uid` |  |  |
| 100.0% | `started` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `subject` |  |  |
| 100.0% | `subject.reference` |  |  |

### CareTeam (3,931 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `encounter` |  |  |
| 100.0% | `encounter.reference` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `managingOrganization` |  |  |
| 100.0% | `managingOrganization[].display` |  |  |
| 100.0% | `managingOrganization[].reference` |  |  |
| 100.0% | `meta` |  |  |
| 100.0% | `meta.profile` |  |  |
| 100.0% | `participant` |  |  |
| 100.0% | `participant[].member` |  |  |
| 100.0% | `participant[].member.display` |  |  |
| 100.0% | `participant[].member.reference` |  |  |
| 100.0% | `participant[].role` |  |  |
| 100.0% | `participant[].role[].coding` |  |  |
| 100.0% | `participant[].role[].coding[].code` |  |  |
| 100.0% | `participant[].role[].coding[].display` |  |  |
| 100.0% | `participant[].role[].coding[].system` |  |  |
| 100.0% | `participant[].role[].text` |  |  |
| 100.0% | `period` |  |  |
| 100.0% | `period.start` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `subject` |  |  |
| 100.0% | `subject.reference` |  |  |
| 52.1% | `reasonCode` |  |  |
| 52.1% | `reasonCode[].coding` |  |  |
| 52.1% | `reasonCode[].coding[].code` |  |  |
| 52.1% | `reasonCode[].coding[].display` |  |  |
| 52.1% | `reasonCode[].coding[].system` |  |  |
| 52.1% | `reasonCode[].text` |  |  |
| 50.1% | `period.end` |  |  |

### CarePlan (3,931 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `careTeam` |  |  |
| 100.0% | `careTeam[].reference` |  |  |
| 100.0% | `category` |  |  |
| 100.0% | `category[].coding` |  |  |
| 100.0% | `category[].coding[].code` |  |  |
| 100.0% | `category[].coding[].display` |  |  |
| 100.0% | `category[].coding[].system` |  |  |
| 100.0% | `category[].text` |  |  |
| 100.0% | `encounter` |  |  |
| 100.0% | `encounter.reference` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `intent` |  |  |
| 100.0% | `meta` |  |  |
| 100.0% | `meta.profile` |  |  |
| 100.0% | `period` |  |  |
| 100.0% | `period.start` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `status` |  |  |
| 100.0% | `subject` |  |  |
| 100.0% | `subject.reference` |  |  |
| 100.0% | `text` |  |  |
| 100.0% | `text.div` |  |  |
| 100.0% | `text.status` |  |  |
| 98.5% | `activity` |  |  |
| 98.5% | `activity[].detail` |  |  |
| 98.5% | `activity[].detail.code` |  |  |
| 98.5% | `activity[].detail.code.coding` |  |  |
| 98.5% | `activity[].detail.code.coding[].code` |  |  |
| 98.5% | `activity[].detail.code.coding[].display` |  |  |
| 98.5% | `activity[].detail.code.coding[].system` |  |  |
| 98.5% | `activity[].detail.code.text` |  |  |
| 98.5% | `activity[].detail.location` |  |  |
| 98.5% | `activity[].detail.location.display` |  |  |
| 98.5% | `activity[].detail.status` |  |  |
| 51.0% | `addresses` |  |  |
| 51.0% | `addresses[].reference` |  |  |
| 50.8% | `activity[].detail.reasonReference` |  |  |
| 50.8% | `activity[].detail.reasonReference[].reference` |  |  |
| 50.1% | `period.end` |  |  |
| 1.1% | `activity[].detail.reasonCode` |  |  |
| 1.1% | `activity[].detail.reasonCode[].coding` |  |  |
| 1.1% | `activity[].detail.reasonCode[].coding[].code` |  |  |
| 1.1% | `activity[].detail.reasonCode[].coding[].display` |  |  |
| 1.1% | `activity[].detail.reasonCode[].coding[].system` |  |  |
| 1.1% | `activity[].detail.reasonCode[].text` |  |  |

### Patient (1,178 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `address` |  |  |
| 100.0% | `address[].city` | *(none)* | MIMIC-IV strips geographic identifiers (HIPAA Safe Harbor). |
| 100.0% | `address[].country` |  |  |
| 100.0% | `address[].extension` |  |  |
| 100.0% | `address[].extension[].extension` |  |  |
| 100.0% | `address[].extension[].extension[].url` |  |  |
| 100.0% | `address[].extension[].extension[].valueDecimal` |  |  |
| 100.0% | `address[].extension[].url` |  |  |
| 100.0% | `address[].line` |  |  |
| 100.0% | `address[].postalCode` | *(none)* | Same — geo PHI removed. |
| 100.0% | `address[].state` | *(none)* | Same — geo PHI removed. |
| 100.0% | `birthDate` | derived → `patients.anchor_age`, `patients.anchor_year` | MIMIC-IV anonymizes dates; no raw birthDate is stored. |
| 100.0% | `communication` |  |  |
| 100.0% | `communication[].language` |  |  |
| 100.0% | `communication[].language.coding` |  |  |
| 100.0% | `communication[].language.coding[].code` | `admissions.language` | Stored at admission level in MIMIC, not patient level. |
| 100.0% | `communication[].language.coding[].display` |  |  |
| 100.0% | `communication[].language.coding[].system` |  |  |
| 100.0% | `communication[].language.text` |  |  |
| 100.0% | `extension` |  |  |
| 100.0% | `extension[].extension` |  |  |
| 100.0% | `extension[].extension[].url` |  |  |
| 100.0% | `extension[].extension[].valueCoding` |  |  |
| 100.0% | `extension[].extension[].valueCoding.code` |  |  |
| 100.0% | `extension[].extension[].valueCoding.display` |  |  |
| 100.0% | `extension[].extension[].valueCoding.system` |  |  |
| 100.0% | `extension[].extension[].valueString` |  |  |
| 100.0% | `extension[].url` | → `admissions.race`, `admissions.insurance`, etc. | Synthea uses us-core-race / us-core-ethnicity extensions on Patient. |
| 100.0% | `extension[].valueAddress` |  |  |
| 100.0% | `extension[].valueAddress.city` |  |  |
| 100.0% | `extension[].valueAddress.country` |  |  |
| 100.0% | `extension[].valueAddress.state` |  |  |
| 100.0% | `extension[].valueCode` |  |  |
| 100.0% | `extension[].valueDecimal` |  |  |
| 100.0% | `extension[].valueString` |  |  |
| 100.0% | `gender` | `patients.gender` | Both use 'M' / 'F'. |
| 100.0% | `id` | `patients.subject_id` | Synthea UUIDs vs. MIMIC int — surrogate-key on load. |
| 100.0% | `identifier` |  |  |
| 100.0% | `identifier[].system` |  |  |
| 100.0% | `identifier[].type` |  |  |
| 100.0% | `identifier[].type.coding` |  |  |
| 100.0% | `identifier[].type.coding[].code` |  |  |
| 100.0% | `identifier[].type.coding[].display` |  |  |
| 100.0% | `identifier[].type.coding[].system` |  |  |
| 100.0% | `identifier[].type.text` |  |  |
| 100.0% | `identifier[].value` |  |  |
| 100.0% | `maritalStatus` |  |  |
| 100.0% | `maritalStatus.coding` |  |  |
| 100.0% | `maritalStatus.coding[].code` | `admissions.marital_status` | Admission-level in MIMIC. |
| 100.0% | `maritalStatus.coding[].display` |  |  |
| 100.0% | `maritalStatus.coding[].system` |  |  |
| 100.0% | `maritalStatus.text` |  |  |
| 100.0% | `meta` |  |  |
| 100.0% | `meta.profile` |  |  |
| 100.0% | `name` |  |  |
| 100.0% | `name[].family` | *(none)* | Names not in MIMIC-IV. |
| 100.0% | `name[].given` | *(none)* | Names not in MIMIC-IV. |
| 100.0% | `name[].use` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `telecom` |  |  |
| 100.0% | `telecom[].system` |  |  |
| 100.0% | `telecom[].use` |  |  |
| 100.0% | `telecom[].value` | *(none)* | Contact info not in MIMIC-IV. |
| 100.0% | `text` |  |  |
| 100.0% | `text.div` |  |  |
| 100.0% | `text.status` |  |  |
| 98.2% | `multipleBirthBoolean` | *(none)* | Not tracked in MIMIC-IV. |
| 80.8% | `name[].prefix` | *(none)* | Names not in MIMIC-IV. |
| 15.1% | `deceasedDateTime` | `patients.dod` | Date-shift applies in real MIMIC; for synthetic cohort, pass through. |
| 1.8% | `multipleBirthInteger` |  |  |
| 1.7% | `name[].suffix` |  |  |

### Provenance (1,178 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `agent` |  |  |
| 100.0% | `agent[].onBehalfOf` |  |  |
| 100.0% | `agent[].onBehalfOf.display` |  |  |
| 100.0% | `agent[].onBehalfOf.reference` |  |  |
| 100.0% | `agent[].type` |  |  |
| 100.0% | `agent[].type.coding` |  |  |
| 100.0% | `agent[].type.coding[].code` |  |  |
| 100.0% | `agent[].type.coding[].display` |  |  |
| 100.0% | `agent[].type.coding[].system` |  |  |
| 100.0% | `agent[].type.text` |  |  |
| 100.0% | `agent[].who` |  |  |
| 100.0% | `agent[].who.display` |  |  |
| 100.0% | `agent[].who.reference` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `meta` |  |  |
| 100.0% | `meta.profile` |  |  |
| 100.0% | `recorded` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `target` |  |  |
| 100.0% | `target[].reference` |  |  |

### AllergyIntolerance (1,141 resources)

| pct | FHIR path | proposed MIMIC-IV target | notes |
|---|---|---|---|
| 100.0% | `category` |  |  |
| 100.0% | `clinicalStatus` |  |  |
| 100.0% | `clinicalStatus.coding` |  |  |
| 100.0% | `clinicalStatus.coding[].code` |  |  |
| 100.0% | `clinicalStatus.coding[].system` |  |  |
| 100.0% | `code` |  |  |
| 100.0% | `code.coding` |  |  |
| 100.0% | `code.coding[].code` |  |  |
| 100.0% | `code.coding[].display` |  |  |
| 100.0% | `code.coding[].system` |  |  |
| 100.0% | `code.text` |  |  |
| 100.0% | `criticality` |  |  |
| 100.0% | `id` |  |  |
| 100.0% | `meta` |  |  |
| 100.0% | `meta.profile` |  |  |
| 100.0% | `patient` |  |  |
| 100.0% | `patient.reference` |  |  |
| 100.0% | `recordedDate` |  |  |
| 100.0% | `resourceType` |  |  |
| 100.0% | `type` |  |  |
| 100.0% | `verificationStatus` |  |  |
| 100.0% | `verificationStatus.coding` |  |  |
| 100.0% | `verificationStatus.coding[].code` |  |  |
| 100.0% | `verificationStatus.coding[].system` |  |  |
| 44.3% | `reaction` |  |  |
| 44.3% | `reaction[].manifestation` |  |  |
| 44.3% | `reaction[].manifestation[].coding` |  |  |
| 44.3% | `reaction[].manifestation[].coding[].code` |  |  |
| 44.3% | `reaction[].manifestation[].coding[].display` |  |  |
| 44.3% | `reaction[].manifestation[].coding[].system` |  |  |
| 44.3% | `reaction[].manifestation[].text` |  |  |
| 41.4% | `reaction[].severity` |  |  |
