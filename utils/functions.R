# -------------------------------------------------------------------------------------------- #
# functions useful for the execution of the main R script
#
# Authors: Anne-Isabelle Graux, Thomas Demarty
#
# Copyright (c) Anne-Isabelle Graux, 2021
# Email: anne-isabelle.graux@inrae.fr
# -------------------------------------------------------------------------------------------- #



CSV_2_RDS <- function(simulation_rcp, horizon) {
  filepath_csv <- paste0("data_csv/",horizon,"_",simulation_rcp,".csv")
  filepath_rds <- paste0("data_rds/",horizon,"_",simulation_rcp,".rds")
  if ((file.exists(filepath_csv)) & !(file.exists(filepath_rds))) {
    print(paste0("Handle file : ", filepath_csv))
    data <- fread(filepath_csv)
    saveRDS(data, filepath_rds)
    rm(data)
  }
}

compute_THI <- function(simulation_rcp,horizon_bounds,horizon_name)
{
  #read rds file
  raw_filepath <- paste0("data_rds/",horizon_bounds, "_", simulation_rcp,".rds")
  raw_data <- readRDS(raw_filepath)
  #put a headline
  colnames(raw_data) <- c("maille_drias","year","month", "DOM", "DOY", "hr", "tmean")
  # Change maille_drias to SAFRAN_id ---
  raw_data <- left_join(raw_data, SAFRAN_DRIAS, by="maille_drias") %>% select(-maille_drias)
  
  data <- raw_data %>% mutate(
    ## date
    date=as.Date(paste0(DOM,"-",month,"-",year),format="%d-%m-%Y"),
    ## wet bulb temperature (Stull et al., 2011)
    Twb=tmean*atan(0.151977*(hr+8.313659)^(1/2))+atan(tmean+hr)-
      atan(hr-1.676331)+0.00391838*(hr)^(3/2)*atan(0.023101*hr)-4.686035,
    alphaThr=17.27*tmean/(237.7+tmean)+log(hr/100),
    ## dew point temperature, formula from Heinrich Gustav Magnus-Tetens(Barenbrug, 1974)
    Tdp=237.7*alphaThr/(17.27-alphaThr),
    ## Temperature-index indices
    #NRC(1971)
    THI1=round((1.8*tmean+32)-((0.55-0.0055*hr)*(1.8*tmean-26.8))),
    #Yousef(1985)
    THI2=round(tmean+0.36*Tdp+41.2),
    #Bianca(1962)
    THI3=round((0.35*tmean+0.65*Twb)*1.8+32),
    #NRC(1971)
    THI4=round((0.55*tmean+0.2*Tdp)*1.8+32+17.5),
    #Bianca(1962)
    THI5=round((0.15*tmean+0.85*Twb)*1.8+32),
    #Thom(1959)
    THI6=round((0.4*(tmean+Twb))*1.8+32+15),
    #NRC(1971)
    THI7=round((tmean+Twb)*0.72+40.6), 
    #Mader(2006)
    THI8=round((0.8*tmean)+((hr/100)*(tmean-14.4))+46.4),
    ##rcp scenario
    rcp=substr(simulation_rcp,4,6),
    ##simulation
    simulation=substr(simulation_rcp,1,2),
    ##horizon time
    horizon=horizon_name) %>%
    select(simulation,rcp,horizon,SAFRAN_id,year,date,
           THI1,THI2,THI3,THI4,THI5,THI6,THI7,THI8
    )
  return(data)
}

draw_THI <- function(THI_filepath,THI,year1,year2,SAFRAN){
  #read rds file
  THI_data <- readRDS(THI_filepath)
  data_to_plot <- THI_data %>%
    select("SAFRAN_id","year","date",paste0(THI)) %>%
    filter(SAFRAN_id==SAFRAN) %>%
    filter(year>=year1&year<=year2)
  g<-ggplot()+geom_line(data=data_to_plot,aes_string(x="date",y=paste0(THI)))
  return(g)
}


#Thermal comfort thresholds were defined according to Collier et al. (2012)
#https://www.researchgate.net/publication/267844201_Quantifying_Heat_Stress_and_Its_Impact_on_Metabolism_and_Performance
#Normal : [0;68[
#Mild stress : [68;72[
#Moderate stress : [72;80[
#severe stress : [80;90[
#Emergengy : [90;...[
compute_annual_days_with_no_stress <- function(simu_rcp,horizon_name, THI_path){
  THI_filename <- paste0(horizon_name, "_",simu_rcp,"_THI.rds")
  THI_filepath <- paste0(THI_path,THI_filename)
  THI_data <- readRDS(THI_filepath)
  
  data <- THI_data %>% group_by(simulation, rcp, horizon, SAFRAN_id, year)
  
  temp <- data %>% select(simulation, rcp, horizon, SAFRAN_id,year) %>% 
    summarise(T1=n()) %>% select(-T1)
  
  N1 <- data %>% filter(THI1<68) %>% summarise(T1=n())
  N2 <- data %>% filter(THI2<68) %>% summarise(T2=n())
  N3 <- data %>% filter(THI3<68) %>% summarise(T3=n())
  N4 <- data %>% filter(THI4<68) %>% summarise(T4=n())
  N5 <- data %>% filter(THI5<68) %>% summarise(T5=n())
  N6 <- data %>% filter(THI6<68) %>% summarise(T6=n())
  N7 <- data %>% filter(THI7<68) %>% summarise(T7=n())
  N8 <- data %>% filter(THI8<68) %>% summarise(T8=n())
  
  nostress <- list(N1, N2, N3, N4, N5, N6, N7, N8) %>% 
    reduce(left_join, by=c("simulation", "rcp", "horizon","SAFRAN_id", "year"))
  
  rm(N1, N2, N3, N4, N5, N6, N7, N8)
  
  nostress <- left_join(temp, nostress, by=c("simulation", "rcp", "horizon", "SAFRAN_id", "year")) %>% 
    mutate(across(T1:T8,~replace(., . == NA, 0)))
  #mutate_each(funs(replace(., which(is.na(.)), 0)))
  
  results <- list("nostress"= nostress)
  
  rm(nostress, temp, data)
  gc(verbose = FALSE)
  
  return(results)
  
}


compute_annual_days_under_mild_stress <- function(simu_rcp,horizon_name, THI_path){
  THI_filename <- paste0(horizon_name, "_",simu_rcp,"_THI.rds")
  THI_filepath <- paste0(THI_path,THI_filename)
  THI_data <- readRDS(THI_filepath)
  
  data <- THI_data %>% group_by(simulation, rcp, horizon, SAFRAN_id, year)
  
  temp <- data %>% select(simulation, rcp, horizon, SAFRAN_id,year) %>% 
    summarise(T1=n()) %>% select(-T1)
  
  Mi1 <- data %>% filter(THI1>=68&THI1<72) %>% summarise(T1=n())
  Mi2 <- data %>% filter(THI2>=68&THI2<72) %>% summarise(T2=n())
  Mi3 <- data %>% filter(THI3>=68&THI3<72) %>% summarise(T3=n())
  Mi4 <- data %>% filter(THI4>=68&THI4<72) %>% summarise(T4=n())
  Mi5 <- data %>% filter(THI5>=68&THI5<72) %>% summarise(T5=n())
  Mi6 <- data %>% filter(THI6>=68&THI6<72) %>% summarise(T6=n())
  Mi7 <- data %>% filter(THI7>=68&THI7<72) %>% summarise(T7=n())
  Mi8 <- data %>% filter(THI8>=68&THI8<72) %>% summarise(T8=n())
  
  mild <- list(Mi1, Mi2, Mi3, Mi4, Mi5, Mi6, Mi7, Mi8) %>%
    reduce(left_join, by=c("simulation", "rcp", "horizon","SAFRAN_id", "year"))
  rm(Mi1, Mi2, Mi3, Mi4, Mi5, Mi6, Mi7, Mi8)
  
  mild <- left_join(temp, mild, by=c("simulation", "rcp", "horizon", "SAFRAN_id", "year")) %>% 
    mutate(across(T1:T8,~replace(., . == NA, 0)))
  #mutate_each(funs(replace(., which(is.na(.)), 0)))
  
  results <- list("mild"= mild)
  
  rm(mild, temp, data)
  gc(verbose = FALSE)
  
  return(results)
  
}


compute_annual_days_under_moderate_stress <- function(simu_rcp,horizon_name, THI_path){
  THI_filename <- paste0(horizon_name, "_",simu_rcp,"_THI.rds")
  THI_filepath <- paste0(THI_path,THI_filename)
  THI_data <- readRDS(THI_filepath)
  
  data <- THI_data %>% group_by(simulation, rcp, horizon, SAFRAN_id, year)
  
  temp <- data %>% select(simulation, rcp, horizon, SAFRAN_id,year) %>% 
    summarise(T1=n()) %>% select(-T1)
  
  Mo1 <- data %>% filter(THI1>=72&THI1<80) %>% summarise(T1=n())
  Mo2 <- data %>% filter(THI2>=72&THI2<80) %>% summarise(T2=n())
  Mo3 <- data %>% filter(THI3>=72&THI3<80) %>% summarise(T3=n())
  Mo4 <- data %>% filter(THI4>=72&THI4<80) %>% summarise(T4=n())
  Mo5 <- data %>% filter(THI5>=72&THI5<80) %>% summarise(T5=n())
  Mo6 <- data %>% filter(THI6>=72&THI6<80) %>% summarise(T6=n())
  Mo7 <- data %>% filter(THI7>=72&THI7<80) %>% summarise(T7=n())
  Mo8 <- data %>% filter(THI8>=72&THI8<80) %>% summarise(T8=n())
  
  moderate <- list(Mo1, Mo2, Mo3, Mo4, Mo5, Mo6, Mo7, Mo8) %>%
    reduce(left_join, by=c("simulation", "rcp", "horizon", "SAFRAN_id", "year"))
 
   rm(Mo1, Mo2, Mo3, Mo4, Mo5, Mo6, Mo7, Mo8)
  
   moderate <- left_join(temp, moderate, by=c("simulation", "rcp", "horizon", "SAFRAN_id", "year")) %>% 
    mutate(across(T1:T8,~replace(., . == NA, 0)))
  #mutate_each(funs(replace(., which(is.na(.)), 0)))
  
  results <- list("moderate"= moderate)
  
  rm(moderate, temp, data)
  gc(verbose = FALSE)
  
  return(results)
  
}

compute_annual_days_under_severe_stress <- function(simu_rcp,horizon_name, THI_path){
  THI_filename <- paste0(horizon_name, "_",simu_rcp,"_THI.rds")
  THI_filepath <- paste0(THI_path,THI_filename)
  THI_data <- readRDS(THI_filepath)
  
  data <- THI_data %>% group_by(simulation, rcp, horizon, SAFRAN_id, year)
  
  temp <- data %>% select(simulation, rcp, horizon, SAFRAN_id,year) %>% 
    summarise(T1=n()) %>% select(-T1)
  
  S1 <- data %>% filter(THI1>=80&THI1<90) %>% summarise(T1=n())
  S2 <- data %>% filter(THI2>=80&THI2<90) %>% summarise(T2=n())
  S3 <- data %>% filter(THI3>=80&THI3<90) %>% summarise(T3=n())
  S4 <- data %>% filter(THI4>=80&THI4<90) %>% summarise(T4=n())
  S5 <- data %>% filter(THI5>=80&THI5<90) %>% summarise(T5=n())
  S6 <- data %>% filter(THI6>=80&THI6<90) %>% summarise(T6=n())
  S7 <- data %>% filter(THI7>=80&THI7<90) %>% summarise(T7=n())
  S8 <- data %>% filter(THI8>=80&THI8<90) %>% summarise(T8=n())
  
  severe <- list(S1, S2, S3, S4, S5, S6, S7, S8) %>%
    reduce(left_join, by=c("simulation", "rcp", "horizon", "SAFRAN_id", "year"))
  
  rm(S1, S2, S3, S4, S5, S6, S7, S8)
  
  severe <- left_join(temp, severe, by=c("simulation", "rcp", "horizon", "SAFRAN_id", "year")) %>% 
    mutate(across(T1:T8,~replace(., . == NA, 0)))
  #mutate_each(funs(replace(., which(is.na(.)), 0)))
  
  results <- list("severe"= severe)
  
  rm(severe, temp, data)
  gc(verbose = FALSE)
  
  return(results)
  
}


compute_annual_days_under_emergency <- function(simu_rcp,horizon_name, THI_path){
  THI_filename <- paste0(horizon_name, "_",simu_rcp,"_THI.rds")
  THI_filepath <- paste0(THI_path,THI_filename)
  THI_data <- readRDS(THI_filepath)
  
  data <- THI_data %>% group_by(simulation, rcp, horizon, SAFRAN_id, year)
  
  temp <- data %>% select(simulation, rcp, horizon, SAFRAN_id,year) %>% 
    summarise(T1=n()) %>% select(-T1)
  
  E1 <- data %>% filter(THI1>=90) %>% summarise(T1=n())
  E2 <- data %>% filter(THI2>=90) %>% summarise(T2=n())
  E3 <- data %>% filter(THI3>=90) %>% summarise(T3=n())
  E4 <- data %>% filter(THI4>=90) %>% summarise(T4=n())
  E5 <- data %>% filter(THI5>=90) %>% summarise(T5=n())
  E6 <- data %>% filter(THI6>=90) %>% summarise(T6=n())
  E7 <- data %>% filter(THI7>=90) %>% summarise(T7=n())
  E8 <- data %>% filter(THI8>=90) %>% summarise(T8=n())
  
  emergency <- list(E1, E2, E3, E4, E5, E6, E7, E8) %>%
    reduce(left_join, by=c("simulation", "rcp", "horizon", "SAFRAN_id", "year"))
  rm(E1, E2, E3, E4, E5, E6, E7, E8)
  
  emergency <- left_join(temp, emergency, by=c("simulation", "rcp", "horizon", "SAFRAN_id", "year")) %>% 
    mutate(across(T1:T8,~replace(., . == NA, 0)))
  #mutate_each(funs(replace(., which(is.na(.)), 0)))
  
  results <- list("emergency"= emergency)
  
  rm(emergency, temp, data)
  gc(verbose = FALSE)
  
  return(results)
  
}