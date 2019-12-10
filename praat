rm(list = ls())
library(PraatR)
library(tidyverse)

# Establecemos directorios y leemos todos los archivos en .wav
dir_raiz<- "/PATH/praat/"
# Creamos un directorio para los decibeles y otro para el pitch
dir_pitch<- "/PATH/praat/Pitch/"
dir_db<- "/PATH/praat/dB/"
lista<- list.files(path = dir_raiz, pattern = ".wav")
archivos<- paste0(dir_raiz, lista)
setwd(dir_raiz)


# Creamos variables num?ricas con la longitud de la lista
p1<- numeric(length(lista))
p2<- numeric(length(lista))
p3<- numeric(length(lista))

# Generamos vectores para que nos guarde en binario para intensity y texto para pitch
nombres<- str_remove(lista, ".wav")
textos<- str_replace(lista,".wav",".txt")

################# OBTENEMOS INTENSIDADES ######################
# Creamos data frame con todos los datos
for (a in 1:length(lista)) {
  db <- praat( "Get intensity (dB)", input=archivos[a]) # Obtenemos la media
  p1[a]<- c(db)
  datos_analizados<- data.frame(Nombre=lista, Media_dB=p1)
  
  #Generamos archivos intensity con PraatR
  praat( "To Intensity...", list(100, 0, "yes"), input=archivos[a], output =paste0(dir_db, nombres[a]), overwrite = TRUE ,filetype="binary")
  
  #Minimo valor
  min_db<- praat( "Get minimum...", list(0, 0, "Parabolic"), input=paste0(dir_db, nombres[a]))
  p2[a]<- c(min_db)
  datos_analizados$Min_intensity = p2
  
  #Maximo valor
  max_db<- praat( "Get maximum...", list(0, 0, "Parabolic"), input=paste0(dir_db, nombres[a]))
  p3[a]<- c(max_db)
  datos_analizados$Max_intensity = p3
}

###################### OBTENEMOS PITCH ######################

for (i in 1:length(lista)) {
  
  #Generamos archivos pitch con PraatR
  praat("To Pitch...", list(0, 75, 600), input=archivos[i], output =paste0(dir_pitch, textos[i]), overwrite = TRUE ,filetype="short text")
  
  
  #Obtenemos la Media
  media_pitch<- praat( "Get mean...", list(0, 0, "Hertz"),input=paste0(dir_pitch, textos[i]))
  p1[i]<- c(media_pitch)
  datos_analizados$Media_Pitch = p1
  
  #Minimo valor
  min_pitch<- praat( "Get minimum...", list(0, 0, "Hertz", "Parabolic"), input=paste0(dir_pitch, textos[i]))
  p2[i]<- c(min_pitch)
  datos_analizados$Min_Pitch = p2
  
  #Maximo valor
  max_pitch<- praat( "Get maximum...", list(0, 0, "Hertz", "Parabolic"), input=paste0(dir_pitch, textos[i]))
  p3[i]<- c(max_pitch)
  datos_analizados$Max_Pitch = p3
}

################# AGREGAMOS EL TIEMPO TOTAL AL DATA FRAME ###################

for (u in 1:length(lista)) {
  tiempo_t<- praat("Get total duration", input =archivos[u] )
  p1[u]<- c(tiempo_t)
  datos_analizados$Tiempo_total = p1
}

# Creamos archivo CSV
setwd(dir_raiz)
write.csv(datos_analizados, file = "Tabla.csv")

#Removemos directorios -- SUBTITUIR PATH CORRESPONDIENTES --
unlink("/PATH/Praat/dB", recursive = TRUE)
unlink("/PATH/Praat/Pitch", recursive = TRUE)
