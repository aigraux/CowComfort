## ------------------------------
## Code developed to :
## - D1: calculate the annual number of days dairy cows are 
##   under stress-free, mild stress, moderate stress, severe stress 
#    and emergency conditions.
## - D2: aggregate D1 according to three types of 
##   calculations (median, 5th percentile, 95th percentile) 
##   by RCP, horizon and SAFRAN grid point
## - D3: draw maps at the scale of France from D2.
##
## Authors: Anne-Isabelle Graux, Thomas Demarty
##
## Copyright (c) Anne-Isabelle Graux, 2023
## Email: anne-isabelle.graux@inrae.fr
## ------------------------------

##load libraries ----
library(dplyr)
library(tidyr)
library(ggplot2)
library(sf) 
library(RColorBrewer)
library(tools)
library(data.table)
library(ggpubr)

memory.size(max=TRUE)
options(encoding = 'UTF-8')

##load fonctions ----
source("utils/functions.R")

##define object lists ----
#list of simulations
simu_list <- list("s1", "s2", "s3", "s4")
#list of RCP
rcp_list = c("2.6","4.5","8.5") 
#list of simulations x RCP
simu_rcp_list <- list("s1_2.6", "s1_4.5", "s1_8.5",
                      "s2_2.6", "s2_4.5", "s2_8.5",
                      "s3_2.6", "s3_4.5", "s3_8.5",
                      "s4_2.6", "s4_4.5", "s4_8.5")
#list of time horizons
horizon_list <-list("1976_2005","2021_2050","2041_2070",
                    "2071_2100")
#list of time horizon names
horizon_name_list = c("Ref","H1","H2","H3")
#list of thermal comfort classes
class_list = c("no_stress","mild_stress","moderate_stress","severe_stress","emergency")
#list of percentile calculations
calcs_list = c("ce5","med","ce95")
#list of data sets
dataset_list = c("Jouzel2014","Drias2020")
#list of variables to plot
list_var <- c("T1med", "T2med", "T3med", "T4med", "T5med", "T6med","T7med", "T8med",
              "T1ce5", "T2ce5", "T3ce5", "T4ce5", "T5ce5", "T6ce5", "T7ce5", "T8ce5",
              "T1ce95", "T2ce95", "T3ce95", "T4ce95", "T5ce95", "T6ce95", "T7ce95", "T8ce95")


#read the correspondence between drias and safran grid points
SAFRAN_DRIAS <- read.csv2("shapefiles/shapefile_SAFRAN/mailles_safran_drias.csv", header=TRUE, sep=",")
SAFRAN_DRIAS <- select(SAFRAN_DRIAS, SAFRAN_id=maille_safran, maille_drias,departement)


##store raw data csv files in rds format (if not already existing) ----
for (simu_rcp in simu_rcp_list) {
  for (horiz in horizon_list) {
    CSV_2_RDS(simulation_rcp = simu_rcp, horizon = horiz)
  }
}

#D1 ----

#compute daily values of the different THI (if not already existing)
for (simu_rcp in simu_rcp_list) {
  h=1
  for (horiz in horizon_list) {
    print(paste0("computing THI for: ",simu_rcp,"_",horiz))
    horizon_name=horizon_name_list[h]
    path_to_file <- paste0("./data_out/THI/",horizon_name, "_",simu_rcp,"_THI.rds")
    
    if(!(file.exists(path_to_file))){
      results<-compute_THI(simu_rcp,horiz,horizon_name)
      saveRDS(results,path_to_file)
      rm(results)
    }
    h=h+1
  }
} 

#compute the annual number of days dairy cows are under stress-free conditions
N_tot <- NULL
for (simu_rcp in simu_rcp_list) {
  for(horizon_name in horizon_name_list){
    print(paste0("computing annual days under stress-free conditions for: ",simu_rcp,"_",horizon_name))
    
    results<-compute_annual_days_with_no_stress(simu_rcp,horizon_name,"./data_out/THI/")
    
    N_tot <- bind_rows(N_tot, results$nostress)
  }
}
saveRDS(N_tot, "./data_out/D1/no_stress.rds")
rm(N_tot)

#compute the annual number of days dairy cows are under mild stress conditions
Mi_tot <- NULL
for (simu_rcp in simu_rcp_list) {
  for(horizon_name in horizon_name_list){
    print(paste0("computing annual days under mild stress conditions for: ",simu_rcp,"_",horizon_name))
    
    results<-compute_annual_days_under_mild_stress(simu_rcp,horizon_name,"./data_out/THI/")
    
    Mi_tot <- bind_rows(Mi_tot, results$mild)
  }
}
saveRDS(Mi_tot, "./data_out/D1/mild_stress.rds")
rm(Mi_tot)

#compute the annual number of days dairy cows are under moderate stress conditions
Mo_tot <- NULL
for (simu_rcp in simu_rcp_list) {
  for(horizon_name in horizon_name_list){
    print(paste0("computing annual days under moderate stress conditionss for: ",simu_rcp,"_",horizon_name))
    
    results<-compute_annual_days_under_moderate_stress(simu_rcp,horizon_name,"./data_out/THI/")
    
    Mo_tot <- bind_rows(Mo_tot, results$moderate)
  }
}
saveRDS(Mo_tot, "./data_out/D1/moderate_stress.rds")
rm(Mo_tot)

##compute the annual number of days dairy cows are under severe stress conditions
S_tot <- NULL
for (simu_rcp in simu_rcp_list) {
  for(horizon_name in horizon_name_list){
    print(paste0("computing annual days under severe stress conditions for: ",simu_rcp,"_",horizon_name))
    
    results<-compute_annual_days_under_severe_stress(simu_rcp,horizon_name,"./data_out/THI/")
    
    S_tot <- bind_rows(S_tot, results$severe)
  }
}
saveRDS(S_tot, "./data_out/D1/severe_stress.rds")
rm(S_tot)

#compute the annual number of days dairy cows are under emergency conditions
E_tot <- NULL
for (simu_rcp in simu_rcp_list) {
  for(horizon_name in horizon_name_list){
    print(paste0("computing annual days under emergency conditions for: ",simu_rcp,"_",horizon_name))
    
    results<-compute_annual_days_under_emergency(simu_rcp,horizon_name,"./data_out/THI/")
    
    E_tot <- bind_rows(E_tot, results$emergency)
  }
}
saveRDS(E_tot, "./data_out/D1/emergency.rds")
rm(E_tot)
rm(results)

# D2 ----

for (class in class_list) {
  data <- readRDS(paste0("data_out/D1/",class,".rds"))
  #temporary##
  data <- data %>% mutate(T1=replace_na(T1,0),
                          T2=replace_na(T2,0),
                          T3=replace_na(T3,0),
                          T4=replace_na(T4,0),
                          T5=replace_na(T5,0),
                          T6=replace_na(T6,0),
                          T7=replace_na(T7,0),
                          T8=replace_na(T8,0))
  ###
  data <- data %>% mutate(dataset=case_when(simulation =="s1"~"Jouzel2014",simulation %in% c("s2", "s3", "s4")~"Drias2020")) 
  agreg_table  <- data %>% group_by(dataset,SAFRAN_id,rcp,horizon) %>%
    summarise(T1med=median(T1), T2med=median(T2), T3med=median(T3),
              T4med=median(T4), T5med=median(T5), T6med=median(T6),
              T7med=median(T7), T8med=median(T8),
              T1ce5=quantile(T1,0.05), T2ce5=quantile(T2,0.05),
              T3ce5=quantile(T3,0.05), T4ce5=quantile(T4,0.05),
              T5ce5=quantile(T5,0.05), T6ce5=quantile(T6,0.05),
              T7ce5=quantile(T7,0.05), T8ce5=quantile(T8,0.05),
              T1ce95=quantile(T1,0.95), T2ce95=quantile(T2, 0.95),
              T3ce95=quantile(T3,0.95), T4ce95=quantile(T4,0.95),
              T5ce95=quantile(T5,0.95), T6ce95=quantile(T6,0.95),
              T7ce95=quantile(T7,0.95), T8ce95=quantile(T8,0.95))
  saveRDS(agreg_table, paste0("data_out/D2/",class,"_agregated.rds"))
}

# D3 ----

#definition of the color of the legend and the maximum limit according to the thermal comfort class
liste_palette<-c(list("Blues"), 
                 list("Greens"),
                 list("Oranges"),
                 list( "Reds"),
                 list("Purples"))
names(liste_palette)=c("no_stress", 
                       "mild_stress",
                       "moderate_stress",
                       "severe_stress",
                       "emergency")

#read the SAFRAN mesh shapefile
maillesSAFRAN <- sf::st_read(
  dsn = "shapefiles/shapefile_SAFRAN/g_safran_l2e.shp", quiet = TRUE)
maillesSAFRAN <- maillesSAFRAN %>% sf::st_transform(4326)

#add the DRIAS mesh identifier
maillesSAFRAN <- dplyr::left_join(maillesSAFRAN,SAFRAN_DRIAS,by=c("GRILLE_S_1"="SAFRAN_id"))

#read the departement shapefile
dpts <- sf::st_read(
  dsn = "shapefiles/shapefile_departements_FR/DEPARTEMENT/DEPARTEMENT.shp", quiet = TRUE)
#the departments of Corsica are not displayed, as raw data are not always available for calculating indicators.
dpts <- dpts %>% dplyr::filter(!NOM_DEPT %in% c("CORSE-DU-SUD","HAUTE-CORSE"))
dpts <- dpts %>% sf::st_transform(4326)
dpts <- dpts %>% select(NOM_DEPT,geometry)
#remove cells that extend beyond the department shapefile
maillesSAFRAN <- st_intersection(x=maillesSAFRAN,y = dpts)

maillesSAFRAN <- maillesSAFRAN %>% select(GRILLE_S_1,NOM_DEPT,departement,geometry)

#map tracing
for(class in class_list) {
  
  data <- readRDS(paste0("data_out/D2/",class,"_agregated.rds"))
  
  for(dataset_name in dataset_list){
    for(horizon_name in horizon_name_list) {
      for (rcp_name in rcp_list) {
        for(variable in list_var){
          
          #data selection and filtering
          data_filtered <- data %>% filter(dataset== dataset_name,
                                           horizon==horizon_name,
                                           rcp==rcp_name)%>%
            select_(indicator=paste0(variable))
          
          #message to inform the user
          print(paste0("drawing map for: ",class," ",variable," ",dataset_name," ",horizon_name," ",rcp_name))
          
          
          #add indicator data to SAFRAN mesh shapefile
          maillesSAFRAN2 <- dplyr::right_join(maillesSAFRAN,data_filtered,by=c("GRILLE_S_1"="SAFRAN_id"))
          
          #data projection in the WGS 84 system (EPSG code 4326).
          maillesSAFRAN2 <- maillesSAFRAN2 %>% sf::st_transform(4326)
          
          #map plotting
          
          #pixelated map with discrete scale (1 pixel = 1 SAFRAN mesh)
          g<-ggplot() +
            geom_sf(data = maillesSAFRAN2,aes(fill = indicator),color=NA)+
            scale_fill_stepsn(colors = RColorBrewer::brewer.pal(7,liste_palette[[class]]),
                              breaks = c(0,50,100,150,200,250,300,350),
                              limits=c(0,366)
                              #,labels = c("0-50","50-100","100-150","150-200","200-250","250-300","300-350","350-366")
            )+
            geom_sf(data = dpts,fill=NA,col="black")+
            labs(x="Longitude (°N)", y="Latitude (°W)") +
            theme(aspect.ratio=1,
                  axis.text=element_text(size=16),
                  axis.title=element_text(size=20,face="bold"),
                  legend.text=element_text(size=14),
                  legend.title=element_text(size=16),
                  legend.position="right")
          
          mapname =paste0("data_out/D3/",class,"/dataset_",dataset_name,"_",variable,"_",class,"_rcp",rcp_name,"_",horizon_name,".png")
          ggsave(mapname, width=11, height=11, dpi=300)
          
          #map without legend and labels stored in the www folder
          q<-g+labs(x="", y="") +
            theme(legend.position = "none",
                  axis.text = element_blank(),
                  axis.ticks =  element_blank(),
                  legend.text=element_text(size=14,vjust=0.5),
                  legend.title=element_blank(),
                  legend.key.width = unit(4.0, "cm"))
          #print(q)
          mapname =paste0("www/dataset_",dataset_name,"_",variable,"_",class,"_rcp",rcp_name,"_",horizon_name,".png")
          ggsave(mapname, width=11, height=11, dpi=300)
          
          #legend per class of thermal confort
          
          my_legend <- get_legend(q, position="bottom")
          as_ggplot(my_legend)
          ggsave(paste0("www/",class,"_legend.png" ), width=10, height=1, dpi=300,scale=1)
          
        }
      }
    }
  }
}
