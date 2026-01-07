##Convert appendix 5, copy/pasted from CMAJ into a useable data frame in R:

library(dplyr)

data <- c("Hypertension 19.24 0.83 -1.88 11.29 0.09 ",
  "Anxiety/Depression 12.85 2.15 6.88 44.33 0.47 ",
  "Painful_condition 11.63 3.41 16.30 82.13 0.87 ",
  "Hearing_loss 11.27 0.96 -3.72 7.73 0.07 ",
  "Irritable_bowel_syndrome 7.61 1.71 -0.77 7.46 0.18 ",
  "Asthma 7.20 1.34 -2.45 21.47 0.18 ",
  "Diabetes 6.58 3.84 9.83 53.95 0.71 ",
  "Prostate_disorders 6.31 1.26 -10.02 5.13 0.01 ",
  "Thyroid_disorders 5.24 0.93 -0.83 1.24 0.08 ",
  "Coronary_heart_disease 4.79 1.49 4.29 68.05 0.46 ",
  "Chronic_kidney_disease 4.50 0.97 16.47 51.24 0.51 ",
  "Diverticular_disease 3.24 0.77 -10.09 9.60 -0.02 ",
  "Chronic_sinusitis 2.96 1.11 -0.19 4.88 0.13 ",
  "Atrial_fibrillation 2.72 5.98 22.93 105.78 1.30 ",
  "Constipation 2.67 3.16 34.58 64.91 1.03 ",
  "Stroke/TIA 2.55 1.53 20.41 88.15 0.77 ",
  "COPD 2.46 3.40 42.29 129.18 1.41 ",
  "Connective_tissue_disorder 2.33 3.00 0.08 27.45 0.40 ",
  "Cancer 2.15 2.65 62.28 103.69 1.50 ",
  "Peptic_ulcer_disease 1.62 0.53 5.69 17.66 0.20",
  "Alcohol_problems 1.60 0.81 11.42 81.19 0.55 ",
  "Substance_misuse 1.19 1.01 2.79 61.41 0.38 ",
  "Psoriasis/eczema 1.16 1.88 -1.46 22.30 0.25 ",
  "Blindness_and_low_vision 1.08 0.33 1.16 24.38 0.15 ",
  "Heart_failure 1.04 2.86 42.26 70.44 1.12 ",
  "Dementia 1.02 1.87 122.92 158.14 2.46 ",
  "Psychosis/bipolar 0.98 2.22 6.64 71.24 0.58 ",
  "Epilepsy 0.97 2.05 17.34 107.94 0.85 ",
  "Inflammatory_bowel_disease 0.96 2.63 -0.45 49.30 0.44 ",
  "Peripheral_vascular_disease 0.88 0.87 15.21 60.09 0.53 ",
  "Anorexia/bulimia 0.55 0.86 8.54 36.01 0.34 ",
  "Chronic_Liver_Disease 0.53 1.27 22.22 77.03 0.72 ",
  "Migraine 0.51 1.12 -4.04 4.65 0.07 ",
  "Learning_disability 0.47 1.15 10.92 55.75 0.47 ",
  "Bronchiectasis 0.43 2.69 5.65 84.15 0.66 ",
  "Multiple_sclerosis 0.28 2.18 8.77 94.29 0.69 ",
  "Parkinson’s_disease 0.28 3.48 40.46 104.13 1.29")


appendix_5 <- as.data.frame(do.call(rbind, strsplit(data, " "))) %>% 
  select(-V2) %>% #remove prevalence, to avoid confusion with local value
  rename(Condition = V1, 
         Consultations = V3,
         Mortality = V4,
         Emergency_Adm = V5,
         General = V6) %>% 
  mutate(Condition = tolower(Condition)) %>% #convert the entire column to lower case for joins
  mutate(Condition = recode(Condition, #recode all the values that differ from column headers in new_cambridge_score
                            "parkinson’s_disease" = "parkinsons",
                            "painful_condition" = "painful_conditions",
                            "stroke/tia" = "stroke_tia",
                            "chronic_liver_disease" = "liver_disease",
                            "multiple_sclerosis" = "ms",
                            "Psychosis/bipolar" = "psychosis_bipolar",
                            "alcohol_problems" = "alc_dependency",
                            "peripheral_vascular_disease" = "periph_vascular",
                            "chronic_kidney_disease" = "ckd",
                            "learning_disability" = "learning_dis",
                            "anxiety/depression"= "anxiety_depression",
                            "coronary_heart_disease" = "chd",
                            "inflammatory_bowel_disease" = "ibd",
                            "substance_misuse" = "substance_misus",
                            "anorexia/bulimia" = "anorexia_bulimia",
                            "psoriasis/eczema" = "eczaema_psoriasis",
                            "peptic_ulcer_disease" = "peptic_ulcer",
                            "irritable_bowel_syndrome" = "ibs",
                            "blindness_and_low_vision" = "visual_impair",
                            "thyroid_disorders" = "thyroid",
                            "prostate_disorders" = "prostate"
                            
                            
  ))

#write.csv(data, "output.csv", row.names = TRUE)