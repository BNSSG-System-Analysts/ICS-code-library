#create lists of nhs numbers in each set you are interested in
anx_dep_list <- unique(cp_data$nhs_number[cp_data$anxiety_depression ==1])
alcdep_dep_list <- unique(cp_data$nhs_number[cp_data$alc_dependency ==1])
submis_list <- unique(cp_data$nhs_number[cp_data$substance_misus ==1])
anorbul_list <- unique(cp_data$nhs_number[cp_data$anorexia_bulimia ==1])
psybi_list <- unique(cp_data$nhs_number[cp_data$psychosis_bipolar ==1])
ld_list <- unique(cp_data$nhs_number[cp_data$learning_dis ==1])

nhs_sets <- list(
  `Anxiety / depress.` = anx_dep_list,
  `Alcohol dependency` = alcdep_dep_list,
  `Subs. misuse` =  submis_list,
  `Anorex. / bulimia.` = anorbul_list,
  `Psychos. / bipolar` = psybi_list,
  `Learning disability` =   ld_list
)

# Calculate overlaps
overlap_matrix <- sapply(nhs_sets, function(x) {
  sapply(nhs_sets, function(y) length(intersect(x, y)))
})


# Set the lower triangular part of the matrix to NA
overlap_matrix[lower.tri(overlap_matrix, diag = FALSE)] <- NA #set to include the diagonal this time

# Convert the matrix to a data frame suitable for ggplot
overlap_df <- as.data.frame(as.table(overlap_matrix))
colnames(overlap_df) <- c("Set1", "Set2", "Overlap")

overlap_df <- overlap_df # %>% filter(Set2 != "Anxiety / depress.", Set1 != "Learning disability")

hiu_overlaps <- ggplot(overlap_df, aes(x = Set1, y = Set2, fill = Overlap)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "#d3d3d3", high = "#853358", na.value = "white", trans = "log1p") +
  geom_text(aes(label = Overlap), na.rm = TRUE) +
  labs(title = "Overlap of NHS numbers ",
       subtitle = "(People with chronic pain and other conditions)",
       x = "Set 1",
       y = "Set 2",
       fill = "Overlap Count",
       caption = "") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  coord_fixed() +
  bnssgtheme() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_text(size = 10)) +
  scale_x_discrete(position = "top",labels = function(x) str_wrap(x, width = 10)) +
  guides(fill = FALSE) 

ggsave("hiu_overlaps_heat.png", hiu_overlaps, width = 9.49, height = 5.72)