# -------------------------------------------------------------------------------------------- #
# functions and hmtl code useful for the developed shiny application
#
# Authors: Anne-Isabelle Graux, Thomas Demarty
#
# Copyright (c) Anne-Isabelle Graux, 2021
# Email: anne-isabelle.graux@inrae.fr
# -------------------------------------------------------------------------------------------- #

#function that returns the names of the images to display according to the selection 
#of the dataset, the thermal comfort class, the RCP and the time horizons by the user
mapnames <- function(dataset, thi, threshold, rcps, horizons){
  # Prepare the list with all map names
  ans = c()
  # The different type of calculation
  calculeType = c("ce5","med","ce95")
  # For the 9 maps
  for (map in 1:9) {
    # For each horizon (1 or 4 values)
    for (hor in horizons) {
      # For each rcps (1 or 4 values)
      for (rcp in rcps) {
        for (calc in calculeType) {
          # T1ce5_normal_rcp2.6_H3.png
          temp <- paste0(dataset,"_",thi,calc,"_",threshold,"_rcp",rcp,"_",hor,".png")
          if (!(temp %in% ans)) {
            ans <- append(ans,temp)
          }
        }
      }
    }
  }
  return(ans)
}

#function that returns the names of the table headers to be displayed according to
#the selection of the RCP and time horizons by the user
rowcolnames <- function(horizons, rcp) {
  ans = c()
  if(length(horizons)>length(rcp)){ans = c(paste0("RCP ",rcp),horizons)}else{ans = c(horizons,paste0("RCP ",rcp))}
  return(ans)
}


legendnames <- function(threshold){
  case_when(threshold=="no_stress"~"no_stress_legend.png" , 
            threshold=="mild_stress"~"mild_stress_legend.png",
            threshold=="moderate_stress"~"moderate_stress_legend.png",
            threshold=="severe_stress"~"severe_stress_legend.png",
            threshold=="emergency"~"emergency_legend.png")}
  
# #function that returns the output to display on the selected thermal comfort class
threshtmlText <- function(threshold) {
  text=case_when(threshold=="no_stress"~"No hyperthermia, the temperature is regulated." , 
            threshold=="mild_stress"~"Rectal temperature exceeds 38.5&degC. Milk yield loss is -1.1 kg/cow/day.",
            threshold=="moderate_stress"~"Rectal temperature exceeds 39&degC. Milk yield loss is -2.7 kg/cow/day.",
            threshold=="severe_stress"~"Rectal temperature exceeds 40&degC. Milk yield loss is -3.9 kg/cow/day.",
            threshold=="emergency"~"Rectal temperature exceeds 41&degC. Milk yield loss is not assessed.")
  return(paste0("<p class='small border border-primary text-muted px-2 py-1'>", text, "</p>"))
}



infotext <- "<div class='container pb-5'>
                
                <H2>Why this interface?</h2><p>
                 
                 This interface allows you to view the evolution of the thermal comfort of dairy cows 
                 under climate change on a French scale. It provides you with several estimates of thermal comfort,
                 and an idea of the uncertainty associated with climate modelling and interannual climate variability.</p>
              
                <h2>The climate data used</h2><p>
                
                 They correspond to part of two climate simulation exercises:
                 <a href='http://www.drias-climat.fr/accompagnement/sections/180'>
                    Jouzel simulations (2014)</a> 
                    and 
                  <a href='http://www.drias-climat.fr/accompagnement/sections/240'>
                    DRIAS simulations (2020)</a> 
                    and were downloaded from the 
                  <a href='https://agroclim.inrae.fr/siclima/extraction/'>
                    SICLIMA portal</a> where only simulations from French laboratories are available.
                  These climate simulation exercises provide daily climate variables from 1950 to 2100,
                    on a spatial grid of 8 km side. In total, twelve climate simulations were considered,
                    which correspond to the crossing of different global climate models (GCM), regional climate models (RCM) 
                    and representative concentration pathways (RCP).</p>
                    
                     <table class='table table-hover table-bordered table-striped'>
                    <thead>
                        <tr>
                          <th scope='col'>Simulation exercise</th>
                          <th scope='col'>Laboratory</th>
                          <th scope='col'>GCM</th>
                          <th scope='col'>RCM</th>
                          <th scope='col'>RCP</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                          <th scope='row'>Jouzel (2014)</th>
                          <td>CNRM</td>
                          <td>CNRM-CM5</td>
                          <td>ALADIN52</td>
                          <td>2.6 ; 4.5 ; 8.5</td>
                        </tr>
                        <tr>
                          <th scope='row'>DRIAS (2020)</th>
                          <td>CNRM</td>
                          <td>CNRM-CM5</td>
                          <td>ALADIN63</td>
                          <td>2.6 ; 4.5 ; 8.5</td>
                        </tr>
                        <tr>
                          <th scope='row'>DRIAS (2020)</th>
                          <td>KNMI</td>
                          <td>CNRM-CM5</td>
                          <td>RACMO22E</td>
                          <td>2.6 ; 4.5 ; 8.5</td>
                        </tr>
                        <tr>
                          <th scope='row'>DRIAS (2020)</th>
                          <td>KNMI</td>
                          <td>EC-EARTH</td>
                          <td>RACMO22E</td>
                          <td>2.6 ; 4.5 ; 8.5</td>
                        </tr>                 
                 </table>
                    
                  These data were downloaded for four 30 year periods or time horizons defined, like in the DRIAS report, as:  
                 'Reference': 1976-2005, 'H1': 2021-2050, 'H2': 2041-2070 and 'H3': 2071-2100.  
                  Additional information on how these data were generated can be found 
                  <a href='http://www.drias-climat.fr/accompagnement/sections/55'>
                    here</a>.
                    
                <h2>Thermal comfort assessment</h2><p>
                
                 We chose to evaluate the thermal comfort of dairy cows on the basis of the calculation of the temperature humidity
                 index (THI) which is the most used indicator to quantify the impact of thermal stress on the physiology of cattle. 
                 Eight calculations of this indicator described in 
                <a href='https://doi.org/10.3168/jds.2008-1370'>
                 Dikmen and Hansen (2009) </a>
                 and in the following table were performed. 
                 The calculation of the different THI is based on two to four daily climate variables, including dry and wet bulb temperatures 
                 (respectively T<sub>db</sub> and T<sub>wb</sub>, both in &degC), dew point temperature (T<sub>dp</sub> in &degC) and relative air humidity (RH in % by volume).
                
                  The wet bulb and dew point temperatures were calculated from the dry bulb temperature (in &degC) and relative air humidity
                  (in % by volume) according to, respectively, the formula of
                  <a href='https://doi.org/10.1175/JAMC-D-11-0143.1'>
                    Stull et al., (2011)</a> and
                   <a href='https://fr.wikipedia.org/wiki/Point_de_rosee'>
                   Heinrich Gustav Magnus-Tetens </a>
                     (Barenbrug, 1974).
                  </p>
                 <table class='table table-hover table-bordered table-striped'>
                    <thead>
                        <tr>
                          <th scope='col'>THI</th>
                          <th scope='col'>Equation</th>
                          <!-- <th scope='col'>Initial application domain</th> -->
                          <!-- <th scope='col'>Source</th> -->
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                          <th scope='row'>THI<sub>1</sub></th>
                          <td> 
                             <math>&#40<mn>1.8</mn> <mi>T<sub>db</sub></mi> <mo>+</mo> <mn>32</mn>&#41; <mo>-</mo> &#40&#40<mn>0.55</mn> <mo>-</mo> <mn>0.0055</mn> <mi>RH</mi>&#41<mo>x</mo>&#40<mn>1.8</mn> <mi>T<sub>db</sub></mi><mo>-</mo><mn>26.8</mn>&#41&#41</math>
                          </td>
                          <!-- <td></td> -->
                           <!-- <td>NRC (1971)</td> -->
                        </tr>
                        <tr>
                          <th scope='row'>THI<sub>2</sub</th>
                          <td><math><mi>T<sub>db</sub></mi> <mo>+</mo> <mn>0.36</mn> T<sub>dp</sub> </mo>+</mo> <mn>41.2</mn></math></td>
                          <!-- <td>heifers</td> -->
                          <!-- <td>Yousef (1985)</td> -->
                        </tr>
                        <tr>
                          <th scope='row'>THI<sub>3</sub</th>
                          <td><math>&#40<mn>0.35</mn> <mi>T<sub>db</sub></mi> <mo>+</mo> <mn>0.65</mn> <mi>T<sub>wb</sub></mi>&#41 <mo>x</mo> <mn>1.8</mn> <mo>+</mo> <mn>32</mn></math> 
                          <!-- <td>bull calves</td> -->
                          <!-- <td>Bianca (1962)</td> -->
                        </tr>
                        <tr>
                          <th scope='row'>THI<sub>4</sub</th>
                          <td><math>&#40<mn>0.55</mn> <mi>T<sub>db</sub></mi> <mo>+</mo> <mn>0.2</mn> <mi>T<sub>dp</sub></mi>&#41 <mo>x</mo> <mn>1.8</mn> <mo>+</mo> <mn>32</mn> <mo>+</mo> <mn>17.5</mn></math></td>
                          <!-- <td></td> -->
                          <!-- <td>NRC (1971)</td> -->
                        </tr>
                        <tr>
                          <th scope='row'>THI<sub>5</sub</th>
                          <td><math>&#40<mn>0.15</mn> <mi>T<sub>db</sub></mi> <mo>+</mo> <mn>0.85</mn> <mi>T<sub>wb</sub></mi>&#41 <mo>x</mo> <mn>1.8</mn> <mo>+</mo> <mn>32</mn></math></td>
                          <!-- <td>bull calves</td> -->
                          <!-- <td>Bianca (1962)</td> -->
                        </tr>
                        <tr>
                          <th scope='row'>THI<sub>6</sub</th>
                          <td><math>&#40<mn>0.4</mn> &#40 <mi>T<sub>db</sub></mi> <mo>+</mo> <mi>T<sub>wb</sub></mi>&#41&#41 <mo>x</mo> <mn>1.8</mn> <mo>+</mo> <mn>32</mn> <mo>+</mo> <mn>15</mn></math></td>
                          <!-- <td>humans</td> -->
                          <!-- <td>Thom (1959)</td> -->
                        </tr>
                        <tr>
                          <th scope='row'>THI<sub>7</sub</th>
                          <td><math>&#40<mi>T<sub>db</sub></mi> <mo>+</mo> <mi>T<sub>wb</sub></mi>&#41 <mo>x</mo> <mn>0.72</mn> <mo>+</mo> <mn>40.6</mn></math></td>
                          <!-- <td></td> -->
                          <!-- <td>NRC (1971)</td> -->
                        </tr>
                        <tr>
                          <th scope='row'>THI<sub>8</sub</th>
                          <td><math><mn>0.8</mn><mi>T<sub>db</sub></mi> <mo>+</mo> &#40&#40<mi>RH</mi><mo>/</mo><mn>100</mn>&#41 <mo>x</mo> &#40<mi>T<sub>db</sub></mi> <mo>-</mo> <mn>14.4</mn>&#41&#41  <mo>+</mo> <mn>46.4</mn></math></td>
                          <!-- <td>fattening cattle</td> -->
                          <!-- <td>Mader (2006)</td> -->
                        </tr>                        
                 </table>
                 <p> 
                 The values of these indices made it possible to compute the number of days per year when dairy cows are 
                 in a ssituation of thermal comfort qualified according to
                  <a href='https://www.researchgate.net/publication/267844201_Quantifying_Heat_Stress_and_Its_Impact_on_Metabolism_and_Performance'>
                 Collier et al., (2012) </a>
                as 'no stress' (THI &lt 68), 'mild stress' (68 &#8804 THI &lt 72), 'moderate stress' (72 &#8804 THI &lt 80), 'severe stress' (80 &#8804 THI &lt 90) and emergency (THI &gt 90). 
                These numbers of days were then aggregated by simulation exercice, SAFRAN grid point, RCP and 30-year period or time horizon. 
                Three types of aggregation have been calculated corresponding to the median and the 5<sup>th</sup> and 95<sup>th</sup> percentiles of the distribution of these numbers of days according to the global climate models,
                the regional climate models of the simulation exercise and the 30 years of the considered time horizon.
                </p>
                </div>"

genfooter <- "<footer class='footer bg-success'>
            <div class='d-flex container-fluid mt-5 py-3 justify-content-between'>
            <span class='text-light'>&copy; INRAE 2021</span>
            <span class='text-light'>Version alpha v 0.0.1</span>
            </div></footer>"

