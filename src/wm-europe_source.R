# wm-europe_source.R
# 
# Copyright (c) Andrea Estandia, 2026, except where indicated
# Date Created: 2026-03-30


# --------------------------------------------------------------------------
# REQUIRES
# --------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(lubridate)
  library(tidyr)
  library(showtext)
  library(reshape2)
  library(data.table)
  library(stringr)
  library(wesanderson)
  library(patchwork)
  library(Matrix)
  library(data.table) 
  library(geosphere)
  library(scales)
  library(purrr)

})


text_size = 24
# --------------------------------------------------------------------------
# PATHS
# --------------------------------------------------------------------------

data_path <- file.path(getwd(), "data")
reports_path <- file.path(getwd(), "reports")
figures_path <- file.path(getwd(), "reports", "plots")

if (!dir.exists(data_path)) {
  dir.create(data_path, recursive = TRUE)
}

if (!dir.exists(figures_path)) {
  dir.create(figures_path, recursive = TRUE)
}

if (!dir.exists(reports_path)) {
  dir.create(reports_path, recursive = TRUE)
}

font_add_google("Roboto Condensed", "roboto_condensed")
showtext_auto() 


'%!in%' <- function(x,y)!('%in%'(x,y))
CalculateEuclideanDistance <- function(vect1, vect2) sqrt(sum((vect1 - vect2)^2)) 

base_theme <- theme_classic() +
  theme(
    panel.grid = element_blank(),
    panel.background = element_blank(),
    text = element_text(family = "roboto_condensed", size = 16),
    plot.tag = element_text(face = "bold", size = 16)
  )
