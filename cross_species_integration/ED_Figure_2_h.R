library(Seurat)
library(dplyr)
library(Matrix)
library(matrixStats)
library(gplots)
library(ggplot2)
library(feather)
library(viridis)

#load data and format
anno <- read_feather("~/NeMO_analysis_folder/Transcriptomics/cross_species_integration/additional_intermediate_files/3_species_anno.feather")
sample.combined <- readRDS("~/NeMO_analysis_folder/Transcriptomics/cross_species_integration/sample.combined_exc_integration.RDS")

anno$cross_species_cluster_label <- sub("human_", "", anno$cross_species_cluster_label)
anno$cross_species_cluster_label <- sub("marmoset_", "", anno$cross_species_cluster_label)
anno$cross_species_cluster_label <- sub("mouse_", "", anno$cross_species_cluster_label)

sample.combined$new_sample_id <- paste(sample.combined$orig.ident, sample.combined$sample_id, sep = "_")
which(is.na(match(sample.combined$new_sample_id, anno$sample_id)))
sample.combined$cross_species_cluster_label <- anno$cross_species_cluster_label[match(sample.combined$new_sample_id, anno$sample_id)]

#exclude nuclei without an integrated cluster association
sample.combined$keep <- "YES"
sample.combined$keep[which(sample.combined$cross_species_cluster_label == "exclude")] <- "NO"
table(sample.combined$keep)
Idents(sample.combined) <- sample.combined$keep
sample.combined <- subset(sample.combined, idents = "YES")

#downsample to 20 nuclei per cluster
data.subset <- sample.combined
Idents(data.subset) <- data.subset$cluster_label
data.subset <- subset(data.subset, downsample = 20)

#subset each species and find DE genes for each species
Idents(data.subset) <- data.subset$orig.ident
data.human <- subset(data.subset, idents = "human")
data.marmoset <- subset(data.subset, idents = "marmoset")
data.mouse <- subset(data.subset, idents = "mouse")
Idents(data.human) <- data.human$cross_species_cluster_label
Idents(data.marmoset) <- data.marmoset$cross_species_cluster_label
Idents(data.mouse) <- data.mouse$cross_species_cluster_label

human.markers <- FindAllMarkers(data.human, assay = "SCT", slot = "counts", only.pos = TRUE)
marmoset.markers <- FindAllMarkers(data.marmoset, assay = "SCT", slot = "counts", only.pos = TRUE)
mouse.markers <- FindAllMarkers(data.mouse, assay = "SCT", slot = "counts", only.pos = TRUE)

#find genes that are DE in same in cl across all 3 species
int_cl <- as.character(unique(human.markers$cluster))
genes_use <- data.frame(matrix(NA, nrow = 1, ncol = ncol(human.markers)))
colnames(genes_use) <- colnames(human.markers)

for(i in 1:length(int_cl)){
  tmp1 <- human.markers[which(human.markers$cluster == int_cl[i]), ]
  tmp2 <- marmoset.markers[which(marmoset.markers$cluster == int_cl[i]), ]
  tmp3 <- mouse.markers[which(mouse.markers$cluster == int_cl[i]), ]
  
  tmp1 <- tmp1[which(tmp1$gene %in% tmp2$gene), ]
  tmp1 <- tmp1[which(tmp1$gene %in% tmp3$gene), ]
  genes_use <- rbind(tmp1, genes_use)
}

genes_use_all <- genes_use[order(match(genes_use$cluster, order)), ]

#order genes and prepare data order for heatmap
order <- c("L2/3 IT", "L5 IT_1", "L5 IT_2", "L5 IT_3", "L6 IT_1", "L6 IT_2", "L6 IT_3", "L6 CT_1", "L6 CT_2", "L6b", "L5 ET_1", "L5 ET_2", "L5/6 NP")

################################################################################
#########  find markers for subclasses - L5 IT        ##########################
################################################################################

cl_of_interest <- c("L5 IT_1", "L5 IT_2", "L5 IT_3")
Idents(data.human) <- data.human$cross_species_cluster_label
Idents(data.marmoset) <- data.marmoset$cross_species_cluster_label
Idents(data.mouse) <- data.mouse$cross_species_cluster_label


human.sub <- subset(data.human, idents = cl_of_interest)
marmoset.sub <- subset(data.marmoset, idents = cl_of_interest)
mouse.sub <- subset(data.mouse, idents = cl_of_interest)

human.sub.markers <- FindAllMarkers(human.sub, assay = "SCT", slot = "counts", only.pos = TRUE)
marmoset.sub.markers <- FindAllMarkers(marmoset.sub, assay = "SCT", slot = "counts", only.pos = TRUE)
mouse.sub.markers <- FindAllMarkers(mouse.sub, assay = "SCT", slot = "counts", only.pos = TRUE)

int_cl <- as.character(unique(human.sub.markers$cluster))
genes_use <- data.frame(matrix(NA, nrow = 1, ncol = ncol(human.sub.markers)))
colnames(genes_use) <- colnames(human.sub.markers)

for(i in 1:length(int_cl)){
  tmp1 <- human.sub.markers[which(human.sub.markers$cluster == int_cl[i]), ]
  tmp2 <- marmoset.sub.markers[which(marmoset.sub.markers$cluster == int_cl[i]), ]
  tmp3 <- mouse.sub.markers[which(mouse.sub.markers$cluster == int_cl[i]), ]
  
  tmp1 <- tmp1[which(tmp1$gene %in% tmp2$gene), ]
  tmp1 <- tmp1[which(tmp1$gene %in% tmp3$gene), ]
  genes_use <- rbind(tmp1, genes_use)
}
genes_use_L5_IT <- genes_use[order(match(genes_use$cluster, order)), ]

################################################################################
#########  find markers for subclasses - L6 IT        ##########################
################################################################################

cl_of_interest <- c("L6 IT_1", "L6 IT_2", "L6 IT_3")
Idents(data.human) <- data.human$cross_species_cluster_label
Idents(data.marmoset) <- data.marmoset$cross_species_cluster_label
Idents(data.mouse) <- data.mouse$cross_species_cluster_label


human.sub <- subset(data.human, idents = cl_of_interest)
marmoset.sub <- subset(data.marmoset, idents = cl_of_interest)
mouse.sub <- subset(data.mouse, idents = cl_of_interest)

human.sub.markers <- FindAllMarkers(human.sub, assay = "SCT", slot = "counts", only.pos = TRUE)
marmoset.sub.markers <- FindAllMarkers(marmoset.sub, assay = "SCT", slot = "counts", only.pos = TRUE)
mouse.sub.markers <- FindAllMarkers(mouse.sub, assay = "SCT", slot = "counts", only.pos = TRUE)

int_cl <- as.character(unique(human.sub.markers$cluster))
genes_use <- data.frame(matrix(NA, nrow = 1, ncol = ncol(human.sub.markers)))
colnames(genes_use) <- colnames(human.sub.markers)

for(i in 1:length(int_cl)){
  tmp1 <- human.sub.markers[which(human.sub.markers$cluster == int_cl[i]), ]
  tmp2 <- marmoset.sub.markers[which(marmoset.sub.markers$cluster == int_cl[i]), ]
  tmp3 <- mouse.sub.markers[which(mouse.sub.markers$cluster == int_cl[i]), ]
  
  tmp1 <- tmp1[which(tmp1$gene %in% tmp2$gene), ]
  tmp1 <- tmp1[which(tmp1$gene %in% tmp3$gene), ]
  genes_use <- rbind(tmp1, genes_use)
}

genes_use_L6_IT <- genes_use[order(match(genes_use$cluster, order)), ]

################################################################################
#########  find markers for subclasses - L6 CT        ##########################
################################################################################

cl_of_interest <- c("L6 CT_1", "L6 CT_2")
Idents(data.human) <- data.human$cross_species_cluster_label
Idents(data.marmoset) <- data.marmoset$cross_species_cluster_label
Idents(data.mouse) <- data.mouse$cross_species_cluster_label


human.sub <- subset(data.human, idents = cl_of_interest)
marmoset.sub <- subset(data.marmoset, idents = cl_of_interest)
mouse.sub <- subset(data.mouse, idents = cl_of_interest)

human.sub.markers <- FindAllMarkers(human.sub, assay = "SCT", slot = "counts", only.pos = TRUE)
marmoset.sub.markers <- FindAllMarkers(marmoset.sub, assay = "SCT", slot = "counts", only.pos = TRUE)
mouse.sub.markers <- FindAllMarkers(mouse.sub, assay = "SCT", slot = "counts", only.pos = TRUE)

int_cl <- as.character(unique(human.sub.markers$cluster))
genes_use <- data.frame(matrix(NA, nrow = 1, ncol = ncol(human.sub.markers)))
colnames(genes_use) <- colnames(human.sub.markers)

for(i in 1:length(int_cl)){
  tmp1 <- human.sub.markers[which(human.sub.markers$cluster == int_cl[i]), ]
  tmp2 <- marmoset.sub.markers[which(marmoset.sub.markers$cluster == int_cl[i]), ]
  tmp3 <- mouse.sub.markers[which(mouse.sub.markers$cluster == int_cl[i]), ]
  
  tmp1 <- tmp1[which(tmp1$gene %in% tmp2$gene), ]
  tmp1 <- tmp1[which(tmp1$gene %in% tmp3$gene), ]
  genes_use <- rbind(tmp1, genes_use)
}

genes_use_L6_CT <- genes_use[order(match(genes_use$cluster, order)), ]

################################################################################
#########  find markers for subclasses - L5 ET        ##########################
################################################################################

cl_of_interest <- c("L5 ET_1", "L5 ET_2")
Idents(data.human) <- data.human$cross_species_cluster_label
Idents(data.marmoset) <- data.marmoset$cross_species_cluster_label
Idents(data.mouse) <- data.mouse$cross_species_cluster_label


human.sub <- subset(data.human, idents = cl_of_interest)
marmoset.sub <- subset(data.marmoset, idents = cl_of_interest)
mouse.sub <- subset(data.mouse, idents = cl_of_interest)

human.sub.markers <- FindAllMarkers(human.sub, assay = "SCT", slot = "counts", only.pos = TRUE)
marmoset.sub.markers <- FindAllMarkers(marmoset.sub, assay = "SCT", slot = "counts", only.pos = TRUE)
mouse.sub.markers <- FindAllMarkers(mouse.sub, assay = "SCT", slot = "counts", only.pos = TRUE)

int_cl <- as.character(unique(human.sub.markers$cluster))
genes_use <- data.frame(matrix(NA, nrow = 1, ncol = ncol(human.sub.markers)))
colnames(genes_use) <- colnames(human.sub.markers)

for(i in 1:length(int_cl)){
  tmp1 <- human.sub.markers[which(human.sub.markers$cluster == int_cl[i]), ]
  tmp2 <- marmoset.sub.markers[which(marmoset.sub.markers$cluster == int_cl[i]), ]
  tmp3 <- mouse.sub.markers[which(mouse.sub.markers$cluster == int_cl[i]), ]
  
  tmp1 <- tmp1[which(tmp1$gene %in% tmp2$gene), ]
  tmp1 <- tmp1[which(tmp1$gene %in% tmp3$gene), ]
  genes_use <- rbind(tmp1, genes_use)
}

genes_use_L5_ET <- genes_use[order(match(genes_use$cluster, order)), ]

################################################################################
#########              Plot genes as heatmap          ##########################
################################################################################
genes_use_all <- genes_use_all %>% group_by(cluster) %>% top_n(n = 5, wt = avg_logFC)
genes_use_all <- as.data.frame(genes_use_all)
genes_use_L5_ET <- genes_use_L5_ET %>% group_by(cluster) %>% top_n(n = 5, wt = avg_logFC)
genes_use_L5_ET <- as.data.frame(genes_use_L5_ET)
genes_use_L5_IT <- genes_use_L5_IT %>% group_by(cluster) %>% top_n(n = 5, wt = avg_logFC)
genes_use_L5_IT <- as.data.frame(genes_use_L5_IT)
genes_use_L6_IT <- genes_use_L6_IT %>% group_by(cluster) %>% top_n(n = 5, wt = avg_logFC)
genes_use_L6_IT <- as.data.frame(genes_use_L6_IT)

genes_use <- rbind(genes_use_all, genes_use_L5_ET, genes_use_L5_IT, genes_use_L6_CT, genes_use_L6_IT)
genes_use <- genes_use[order(match(genes_use$cluster, order)), ]

data_use <- data.mouse
Idents(data_use) <- data_use$cross_species_cluster_label
data_use <- subset(data_use, downsample = 20)
data_use <- ScaleData(data_use, assay = "SCT")
levels(data_use) <- order


DoHeatmap(data_use, assay = "SCT", slot = "scale.data", features = unique(genes_use$gene)) + NoLegend() +
  scale_fill_gradientn(colors = c("white", "white", "#ae5a8c")) +
  theme(axis.text.y = element_text(size = 7))


