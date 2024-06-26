# 95-octane prices

rm(list=ls())

library(rvest)
library(tidyverse)
library(esquisse)
library(ggplot2)
library(openxlsx)

#creating the soup of company names and locations
link = paste0("https://holtankoljak.hu/index.php?ua_map=1&uz_tip=1&mycity=3338&myrad=500#tartalom"   , "")
page = read_html(link)
company = page %>% html_nodes("a") %>% html_attr('href')

#Cutting down the attributes in the beginning selected by error while determining the first appearing brand
num <- 0
stop <- 0
while (stop == 0) {
  num <- num + 1
  if ((substr(company[num],1,4)) == "mol_") {
    brand = "MOL"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "shell_") {
    brand = "Shell"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "omv_") {
    brand = "OMV"
    stop <- 1
  }
  else if ((substr(company[num],1,7)) == "lukoil_") {
    brand = "Orlen"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "avia_") {
    brand = "Avia"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "mobil_") {
    brand = "Mobil Petrol"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "oil_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "oil!_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "nkm-") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "auchan") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "magan_") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,3)) == "nit") {
    brand = "Other"
    stop <- 1
  }
}

company <- company[num:length(company)]

#Cutting down the attributes in the end selected by error
num <- 0
stop <- 0

while (stop == 0){
  num <- num + 1
  if ((substr(company[num],1,5)) == "https"){
    stop <- 1
    endnumber <- num
  }
}

company <- company[1:(endnumber - 1)]
company <- company[1:(length(company)/2)]

rm(num)
rm(stop)

#Establishing a dataframe of the companies in order
brands <- data.frame(brand)

for (number in c(2:(length(company)/2))) {
  if ((substr(company[2*number],1,4)) == "mol_") {
    brands[nrow(brands) + 1,] = "MOL"
  }
  else if ((substr(company[2*number],1,6)) == "shell_") {
    brands[nrow(brands) + 1,] = "Shell"
  }
  else if ((substr(company[2*number],1,4)) == "omv_") {
    brands[nrow(brands) + 1,] = "OMV"
  }
  else if ((substr(company[2*number],1,7)) == "lukoil_") {
    brands[nrow(brands) + 1,] = "Orlen"
  }
  else if ((substr(company[2*number],1,5)) == "avia_") {
    brands[nrow(brands) + 1,] = "Avia"
  }
  else if ((substr(company[2*number],1,6)) == "mobil_") {
    brands[nrow(brands) + 1,] = "Mobil Petrol"
  }
  else if ((substr(company[2*number],1,4)) == "oil_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else if ((substr(company[2*number],1,5)) == "oil!_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else {
    brands[nrow(brands) + 1,] = "Other"
  }
}


#Using another soup, getting the location and prices.
mixed = page %>% html_nodes("td") %>% html_text()

#Cleaning attributes: first three and occasional "activebanner" attributes. Resulting soup of lines contain useful information periodically. Period of 4.
mixed <- mixed[4:length(mixed)]
num <- 1
mixed2 <- NULL
for (i in 1:length(mixed)){
  if (substring(mixed[i],1,14) == "activateBanner"){
    num <- num + 1
  }else {
    mixed2 <- append(mixed2,mixed[num])
    num <- num + 1
  }
}
soup <- mixed2[1:(4*nrow(brands))]
rm(num, mixed, mixed2)


#Extracting prices with one decimal.
comma_position <- 19
stop <- 0
while (stop == 0){
  comma_position <- comma_position + 1
  if (substring(soup[2],comma_position,comma_position) == "."){
    stop <- 1
  }
}

prices <- as.data.frame(as.numeric(substring(soup[2],19,comma_position + 1)))
colnames(prices) <- "price"

for (i in 2:nrow(brands)){
  comma_position <- 19
  stop <- 0
  while (stop == 0){
    comma_position <- comma_position + 1
    if (substring(soup[i*4-2],comma_position,comma_position) == "."){
      stop <- 1
    }
  }
  newdata <- as.data.frame(as.numeric(substring(soup[i*4-2],19,comma_position + 1)))
  colnames(newdata) <- "price"
  prices <- rbind(prices, newdata)
}

rm(comma_position, stop, newdata)

#Extracting the locations of the fuel stations using the soup.
locations <- as.data.frame(soup[3])
colnames(locations) <- "location"
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(soup[i*4-1])
  colnames(newdata) <- "location"
  locations <- rbind(locations, newdata)
}

#Creating the master dataframe with brand, price, location and time stamp.
date <- as.data.frame(Sys.Date())
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(Sys.Date())
  date <- rbind(date, newdata)
}
colnames(date) <- "date"
rm(newdata)

#Merging brand, price, location and date as well as indicating fuel type.
fuel <- cbind(brands, prices, locations, date)
fuel$petrol <- "95 octane petrol"

#Saving out results
current_date <- Sys.Date()
data_frame_name <- paste("95_octane_petrol_", current_date, sep = "")
assign(data_frame_name, fuel)
file_name <- paste('data/',data_frame_name, ".csv", sep = "")
write.csv(get(data_frame_name), file = file_name, fileEncoding = "UTF-8", row.names = FALSE)


# 98-octane prices


#repeating the whole procedure to obtain 98-octane petrol prices.
rm(list=ls())

library(rvest)
library(tidyverse)
library(esquisse)
library(ggplot2)
library(openxlsx)

#creating the soup of company names and locations
link = paste0("https://holtankoljak.hu/index.php?ua_map=1&uz_tip=8&mycity=3338&myrad=500#tartalom"   , "")
page = read_html(link)
company = page %>% html_nodes("a") %>% html_attr('href')

#Cutting down the attributes in the beginning selected by error while determining the first appearing brand
num <- 0
stop <- 0
while (stop == 0) {
  num <- num + 1
  if ((substr(company[num],1,4)) == "mol_") {
    brand = "MOL"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "shell_") {
    brand = "Shell"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "omv_") {
    brand = "OMV"
    stop <- 1
  }
  else if ((substr(company[num],1,7)) == "lukoil_") {
    brand = "Orlen"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "avia_") {
    brand = "Avia"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "mobil_") {
    brand = "Mobil Petrol"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "oil_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "oil!_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "nkm-") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "auchan") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "magan_") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,3)) == "nit") {
    brand = "Other"
    stop <- 1
  }
}

company <- company[num:length(company)]

#Cutting down the attributes in the end selected by error
num <- 0
stop <- 0

while (stop == 0){
  num <- num + 1
  if ((substr(company[num],1,5)) == "https"){
    stop <- 1
    endnumber <- num
  }
}

company <- company[1:(endnumber - 1)]
company <- company[1:(length(company)/2)]

rm(num)
rm(stop)

#Establishing a dataframe of the companies in order
brands <- data.frame(brand)

for (number in c(2:(length(company)/2))) {
  if ((substr(company[2*number],1,4)) == "mol_") {
    brands[nrow(brands) + 1,] = "MOL"
  }
  else if ((substr(company[2*number],1,6)) == "shell_") {
    brands[nrow(brands) + 1,] = "Shell"
  }
  else if ((substr(company[2*number],1,4)) == "omv_") {
    brands[nrow(brands) + 1,] = "OMV"
  }
  else if ((substr(company[2*number],1,7)) == "lukoil_") {
    brands[nrow(brands) + 1,] = "Orlen"
  }
  else if ((substr(company[2*number],1,5)) == "avia_") {
    brands[nrow(brands) + 1,] = "Avia"
  }
  else if ((substr(company[2*number],1,6)) == "mobil_") {
    brands[nrow(brands) + 1,] = "Mobil Petrol"
  }
  else if ((substr(company[2*number],1,4)) == "oil_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else if ((substr(company[2*number],1,5)) == "oil!_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else {
    brands[nrow(brands) + 1,] = "Other"
  }
}

#Using another soup, getting the location and prices.
mixed = page %>% html_nodes("td") %>% html_text()

#Cleaning attributes: first three and occasional "activebanner" attributes. Resulting soup of lines contain useful information periodically. Period of 4.
mixed <- mixed[4:length(mixed)]
num <- 1
mixed2 <- NULL
for (i in 1:length(mixed)){
  if (substring(mixed[i],1,14) == "activateBanner"){
    num <- num + 1
  }else {
    mixed2 <- append(mixed2,mixed[num])
    num <- num + 1
  }
}
soup <- mixed2[1:(4*nrow(brands))]
rm(num, mixed, mixed2)


#Extracting prices with one decimal.
comma_position <- 19
stop <- 0
while (stop == 0){
  comma_position <- comma_position + 1
  if (substring(soup[2],comma_position,comma_position) == "."){
    stop <- 1
  }
}

prices <- as.data.frame(as.numeric(substring(soup[2],19,comma_position + 1)))
colnames(prices) <- "price"

for (i in 2:nrow(brands)){
  comma_position <- 19
  stop <- 0
  while (stop == 0){
    comma_position <- comma_position + 1
    if (substring(soup[i*4-2],comma_position,comma_position) == "."){
      stop <- 1
    }
  }
  newdata <- as.data.frame(as.numeric(substring(soup[i*4-2],19,comma_position + 1)))
  colnames(newdata) <- "price"
  prices <- rbind(prices, newdata)
}

rm(comma_position, stop, newdata)

#Extracting the locations of the fuel stations using the soup.
locations <- as.data.frame(soup[3])
colnames(locations) <- "location"
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(soup[i*4-1])
  colnames(newdata) <- "location"
  locations <- rbind(locations, newdata)
}

#Creating the master dataframe with brand, price, location and time stamp.
date <- as.data.frame(Sys.Date())
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(Sys.Date())
  date <- rbind(date, newdata)
}
colnames(date) <- "date"
rm(newdata)

#Merging brand, price, location and date as well as indicating fuel type.
fuel <- cbind(brands, prices, locations, date)
fuel$petrol <- "98 octane petrol"

#Saving out results
current_date <- Sys.Date()
data_frame_name <- paste("98_octane_petrol_", current_date, sep = "")
assign(data_frame_name, fuel)
file_name <- paste('data/',data_frame_name, ".csv", sep = "")
write.csv(get(data_frame_name), file = file_name, fileEncoding = "UTF-8", row.names = FALSE)


# 100-octane prices

#repeating the whole procedure to obtain 100-octane petrol prices.
rm(list=ls())

library(rvest)
library(tidyverse)
library(esquisse)
library(ggplot2)
library(openxlsx)

#creating the soup of company names and locations
link = paste0("https://holtankoljak.hu/index.php?ua_map=1&uz_tip=4&mycity=3338&myrad=500#tartalom"   , "")
page = read_html(link)
company = page %>% html_nodes("a") %>% html_attr('href')

#Cutting down the attributes in the beginning selected by error while determining the first appearing brand
num <- 0
stop <- 0
while (stop == 0) {
  num <- num + 1
  if ((substr(company[num],1,4)) == "mol_") {
    brand = "MOL"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "shell_") {
    brand = "Shell"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "omv_") {
    brand = "OMV"
    stop <- 1
  }
  else if ((substr(company[num],1,7)) == "lukoil_") {
    brand = "Orlen"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "avia_") {
    brand = "Avia"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "mobil_") {
    brand = "Mobil Petrol"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "oil_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "oil!_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "nkm-") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "auchan") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "magan_") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,3)) == "nit") {
    brand = "Other"
    stop <- 1
  }
}

company <- company[num:length(company)]

#Cutting down the attributes in the end selected by error
num <- 0
stop <- 0

while (stop == 0){
  num <- num + 1
  if ((substr(company[num],1,5)) == "https"){
    stop <- 1
    endnumber <- num
  }
}

company <- company[1:(endnumber - 1)]
company <- company[1:(length(company)/2)]

rm(num)
rm(stop)

#Establishing a dataframe of the companies in order
brands <- data.frame(brand)

for (number in c(2:(length(company)/2))) {
  if ((substr(company[2*number],1,4)) == "mol_") {
    brands[nrow(brands) + 1,] = "MOL"
  }
  else if ((substr(company[2*number],1,6)) == "shell_") {
    brands[nrow(brands) + 1,] = "Shell"
  }
  else if ((substr(company[2*number],1,4)) == "omv_") {
    brands[nrow(brands) + 1,] = "OMV"
  }
  else if ((substr(company[2*number],1,7)) == "lukoil_") {
    brands[nrow(brands) + 1,] = "Orlen"
  }
  else if ((substr(company[2*number],1,5)) == "avia_") {
    brands[nrow(brands) + 1,] = "Avia"
  }
  else if ((substr(company[2*number],1,6)) == "mobil_") {
    brands[nrow(brands) + 1,] = "Mobil Petrol"
  }
  else if ((substr(company[2*number],1,4)) == "oil_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else if ((substr(company[2*number],1,5)) == "oil!_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else {
    brands[nrow(brands) + 1,] = "Other"
  }
}

#Using another soup, getting the location and prices.
mixed = page %>% html_nodes("td") %>% html_text()

#Cleaning attributes: first three and occasional "activebanner" attributes. Resulting soup of lines contain useful information periodically. Period of 4.
mixed <- mixed[4:length(mixed)]
num <- 1
mixed2 <- NULL
for (i in 1:length(mixed)){
  if (substring(mixed[i],1,14) == "activateBanner"){
    num <- num + 1
  }else {
    mixed2 <- append(mixed2,mixed[num])
    num <- num + 1
  }
}
soup <- mixed2[1:(4*nrow(brands))]
rm(num, mixed, mixed2)


#Extracting prices with one decimal.
comma_position <- 19
stop <- 0
while (stop == 0){
  comma_position <- comma_position + 1
  if (substring(soup[2],comma_position,comma_position) == "."){
    stop <- 1
  }
}

prices <- as.data.frame(as.numeric(substring(soup[2],19,comma_position + 1)))
colnames(prices) <- "price"

for (i in 2:nrow(brands)){
  comma_position <- 19
  stop <- 0
  while (stop == 0){
    comma_position <- comma_position + 1
    if (substring(soup[i*4-2],comma_position,comma_position) == "."){
      stop <- 1
    }
  }
  newdata <- as.data.frame(as.numeric(substring(soup[i*4-2],19,comma_position + 1)))
  colnames(newdata) <- "price"
  prices <- rbind(prices, newdata)
}

rm(comma_position, stop, newdata)

#Extracting the locations of the fuel stations using the soup.
locations <- as.data.frame(soup[3])
colnames(locations) <- "location"
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(soup[i*4-1])
  colnames(newdata) <- "location"
  locations <- rbind(locations, newdata)
}

#Creating the master dataframe with brand, price, location and time stamp.
date <- as.data.frame(Sys.Date())
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(Sys.Date())
  date <- rbind(date, newdata)
}
colnames(date) <- "date"
rm(newdata)

#Merging brand, price, location and date as well as indicating fuel type.
fuel <- cbind(brands, prices, locations, date)
fuel$petrol <- "100 octane petrol"

#Saving out results
current_date <- Sys.Date()
data_frame_name <- paste("100_octane_petrol_", current_date, sep = "")
assign(data_frame_name, fuel)
file_name <- paste('data/',data_frame_name, ".csv", sep = "")
write.csv(get(data_frame_name), file = file_name, fileEncoding = "UTF-8", row.names = FALSE)


# Premium octane petrol

#repeating the whole procedure to obtain premium octane petrol prices.
rm(list=ls())

library(rvest)
library(tidyverse)
library(esquisse)
library(ggplot2)
library(openxlsx)

#creating the soup of company names and locations
link = paste0("https://holtankoljak.hu/index.php?ua_map=1&uz_tip=7&mycity=3338&myrad=500#tartalom"   , "")
page = read_html(link)
company = page %>% html_nodes("a") %>% html_attr('href')

#Cutting down the attributes in the beginning selected by error while determining the first appearing brand
num <- 0
stop <- 0
while (stop == 0) {
  num <- num + 1
  if ((substr(company[num],1,4)) == "mol_") {
    brand = "MOL"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "shell_") {
    brand = "Shell"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "omv_") {
    brand = "OMV"
    stop <- 1
  }
  else if ((substr(company[num],1,7)) == "lukoil_") {
    brand = "Orlen"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "avia_") {
    brand = "Avia"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "mobil_") {
    brand = "Mobil Petrol"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "oil_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "oil!_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "nkm-") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "auchan") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "magan_") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,3)) == "nit") {
    brand = "Other"
    stop <- 1
  }
}

company <- company[num:length(company)]

#Cutting down the attributes in the end selected by error
num <- 0
stop <- 0

while (stop == 0){
  num <- num + 1
  if ((substr(company[num],1,5)) == "https"){
    stop <- 1
    endnumber <- num
  }
}

company <- company[1:(endnumber - 1)]
company <- company[1:(length(company)/2)]

rm(num)
rm(stop)

#Establishing a dataframe of the companies in order
brands <- data.frame(brand)

for (number in c(2:(length(company)/2))) {
  if ((substr(company[2*number],1,4)) == "mol_") {
    brands[nrow(brands) + 1,] = "MOL"
  }
  else if ((substr(company[2*number],1,6)) == "shell_") {
    brands[nrow(brands) + 1,] = "Shell"
  }
  else if ((substr(company[2*number],1,4)) == "omv_") {
    brands[nrow(brands) + 1,] = "OMV"
  }
  else if ((substr(company[2*number],1,7)) == "lukoil_") {
    brands[nrow(brands) + 1,] = "Orlen"
  }
  else if ((substr(company[2*number],1,5)) == "avia_") {
    brands[nrow(brands) + 1,] = "Avia"
  }
  else if ((substr(company[2*number],1,6)) == "mobil_") {
    brands[nrow(brands) + 1,] = "Mobil Petrol"
  }
  else if ((substr(company[2*number],1,4)) == "oil_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else if ((substr(company[2*number],1,5)) == "oil!_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else {
    brands[nrow(brands) + 1,] = "Other"
  }
}

#Using another soup, getting the location and prices.
mixed = page %>% html_nodes("td") %>% html_text()

#Cleaning attributes: first three and occasional "activebanner" attributes. Resulting soup of lines contain useful information periodically. Period of 4.
mixed <- mixed[4:length(mixed)]
num <- 1
mixed2 <- NULL
for (i in 1:length(mixed)){
  if (substring(mixed[i],1,14) == "activateBanner"){
    num <- num + 1
  }else {
    mixed2 <- append(mixed2,mixed[num])
    num <- num + 1
  }
}
soup <- mixed2[1:(4*nrow(brands))]
rm(num, mixed, mixed2)


#Extracting prices with one decimal.
comma_position <- 21
stop <- 0
while (stop == 0){
  comma_position <- comma_position + 1
  if (substring(soup[2],comma_position,comma_position) == "."){
    stop <- 1
  }
}

prices <- as.data.frame(as.numeric(substring(soup[2],21,comma_position + 1)))
colnames(prices) <- "price"

for (i in 2:nrow(brands)){
  comma_position <- 21
  stop <- 0
  while (stop == 0){
    comma_position <- comma_position + 1
    if (substring(soup[i*4-2],comma_position,comma_position) == "."){
      stop <- 1
    }
  }
  newdata <- as.data.frame(as.numeric(substring(soup[i*4-2],21,comma_position + 1)))
  colnames(newdata) <- "price"
  prices <- rbind(prices, newdata)
}

rm(comma_position, stop, newdata)

#Extracting the locations of the fuel stations using the soup.
locations <- as.data.frame(soup[3])
colnames(locations) <- "location"
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(soup[i*4-1])
  colnames(newdata) <- "location"
  locations <- rbind(locations, newdata)
}

#Creating the master dataframe with brand, price, location and time stamp.
date <- as.data.frame(Sys.Date())
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(Sys.Date())
  date <- rbind(date, newdata)
}
colnames(date) <- "date"
rm(newdata)

#Merging brand, price, location and date as well as indicating fuel type.
fuel <- cbind(brands, prices, locations, date)
fuel$petrol <- "premium octane petrol"

#Saving out results
current_date <- Sys.Date()
data_frame_name <- paste("premium_octane_petrol_", current_date, sep = "")
assign(data_frame_name, fuel)
file_name <- paste('data/',data_frame_name, ".csv", sep = "")
write.csv(get(data_frame_name), file = file_name, fileEncoding = "UTF-8", row.names = FALSE)


# Diesel

#repeating the whole procedure to obtain diesel prices.
rm(list=ls())

library(rvest)
library(tidyverse)
library(esquisse)
library(ggplot2)
library(openxlsx)

#creating the soup of company names and locations
link = paste0("https://holtankoljak.hu/index.php?ua_map=1&uz_tip=2&mycity=3338&myrad=500#tartalom"   , "")
page = read_html(link)
company = page %>% html_nodes("a") %>% html_attr('href')

#Cutting down the attributes in the beginning selected by error while determining the first appearing brand
num <- 0
stop <- 0
while (stop == 0) {
  num <- num + 1
  if ((substr(company[num],1,4)) == "mol_") {
    brand = "MOL"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "shell_") {
    brand = "Shell"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "omv_") {
    brand = "OMV"
    stop <- 1
  }
  else if ((substr(company[num],1,7)) == "lukoil_") {
    brand = "Orlen"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "avia_") {
    brand = "Avia"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "mobil_") {
    brand = "Mobil Petrol"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "oil_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "oil!_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "nkm-") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "auchan") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "magan_") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,3)) == "nit") {
    brand = "Other"
    stop <- 1
  }
}

company <- company[num:length(company)]

#Cutting down the attributes in the end selected by error
num <- 0
stop <- 0

while (stop == 0){
  num <- num + 1
  if ((substr(company[num],1,5)) == "https"){
    stop <- 1
    endnumber <- num
  }
}

company <- company[1:(endnumber - 1)]
company <- company[1:(length(company)/2)]

rm(num)
rm(stop)

#Establishing a dataframe of the companies in order
brands <- data.frame(brand)

for (number in c(2:(length(company)/2))) {
  if ((substr(company[2*number],1,4)) == "mol_") {
    brands[nrow(brands) + 1,] = "MOL"
  }
  else if ((substr(company[2*number],1,6)) == "shell_") {
    brands[nrow(brands) + 1,] = "Shell"
  }
  else if ((substr(company[2*number],1,4)) == "omv_") {
    brands[nrow(brands) + 1,] = "OMV"
  }
  else if ((substr(company[2*number],1,7)) == "lukoil_") {
    brands[nrow(brands) + 1,] = "Orlen"
  }
  else if ((substr(company[2*number],1,5)) == "avia_") {
    brands[nrow(brands) + 1,] = "Avia"
  }
  else if ((substr(company[2*number],1,6)) == "mobil_") {
    brands[nrow(brands) + 1,] = "Mobil Petrol"
  }
  else if ((substr(company[2*number],1,4)) == "oil_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else if ((substr(company[2*number],1,5)) == "oil!_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else {
    brands[nrow(brands) + 1,] = "Other"
  }
}

#Using another soup, getting the location and prices.
mixed = page %>% html_nodes("td") %>% html_text()

#Cleaning attributes: first three and occasional "activebanner" attributes. Resulting soup of lines contain useful information periodically. Period of 4.
mixed <- mixed[4:length(mixed)]
num <- 1
mixed2 <- NULL
for (i in 1:length(mixed)){
  if (substring(mixed[i],1,14) == "activateBanner"){
    num <- num + 1
  }else {
    mixed2 <- append(mixed2,mixed[num])
    num <- num + 1
  }
}
soup <- mixed2[1:(4*nrow(brands))]
rm(num, mixed, mixed2)


#Extracting prices with one decimal.
comma_position <- 10
stop <- 0
while (stop == 0){
  comma_position <- comma_position + 1
  if (substring(soup[2],comma_position,comma_position) == "."){
    stop <- 1
  }
}

prices <- as.data.frame(as.numeric(substring(soup[2],10,comma_position + 1)))
colnames(prices) <- "price"

for (i in 2:nrow(brands)){
  comma_position <- 10
  stop <- 0
  while (stop == 0){
    comma_position <- comma_position + 1
    if (substring(soup[i*4-2],comma_position,comma_position) == "."){
      stop <- 1
    }
  }
  newdata <- as.data.frame(as.numeric(substring(soup[i*4-2],10,comma_position + 1)))
  colnames(newdata) <- "price"
  prices <- rbind(prices, newdata)
}

rm(comma_position, stop, newdata)

#Extracting the locations of the fuel stations using the soup.
locations <- as.data.frame(soup[3])
colnames(locations) <- "location"
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(soup[i*4-1])
  colnames(newdata) <- "location"
  locations <- rbind(locations, newdata)
}

#Creating the master dataframe with brand, price, location and time stamp.
date <- as.data.frame(Sys.Date())
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(Sys.Date())
  date <- rbind(date, newdata)
}
colnames(date) <- "date"
rm(newdata)

#Merging brand, price, location and date as well as indicating fuel type.
fuel <- cbind(brands, prices, locations, date)
fuel$petrol <- "diesel"

#Saving out results
current_date <- Sys.Date()
data_frame_name <- paste("diesel_", current_date, sep = "")
assign(data_frame_name, fuel)
file_name <- paste('data/',data_frame_name, ".csv", sep = "")
write.csv(get(data_frame_name), file = file_name, fileEncoding = "UTF-8", row.names = FALSE)


# Premium diesel

#repeating the whole procedure to obtain premium diesel prices.
rm(list=ls())

library(rvest)
library(tidyverse)
library(esquisse)
library(ggplot2)
library(openxlsx)

#creating the soup of company names and locations
link = paste0("https://holtankoljak.hu/index.php?ua_map=1&uz_tip=6&mycity=3338&myrad=500#tartalom"   , "")
page = read_html(link)
company = page %>% html_nodes("a") %>% html_attr('href')

#Cutting down the attributes in the beginning selected by error while determining the first appearing brand
num <- 0
stop <- 0
while (stop == 0) {
  num <- num + 1
  if ((substr(company[num],1,4)) == "mol_") {
    brand = "MOL"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "shell_") {
    brand = "Shell"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "omv_") {
    brand = "OMV"
    stop <- 1
  }
  else if ((substr(company[num],1,7)) == "lukoil_") {
    brand = "Orlen"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "avia_") {
    brand = "Avia"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "mobil_") {
    brand = "Mobil Petrol"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "oil_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "oil!_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "nkm-") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "auchan") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "magan_") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,3)) == "nit") {
    brand = "Other"
    stop <- 1
  }
}

company <- company[num:length(company)]

#Cutting down the attributes in the end selected by error
num <- 0
stop <- 0

while (stop == 0){
  num <- num + 1
  if ((substr(company[num],1,5)) == "https"){
    stop <- 1
    endnumber <- num
  }
}

company <- company[1:(endnumber - 1)]
company <- company[1:(length(company)/2)]

rm(num)
rm(stop)

#Establishing a dataframe of the companies in order
brands <- data.frame(brand)

for (number in c(2:(length(company)/2))) {
  if ((substr(company[2*number],1,4)) == "mol_") {
    brands[nrow(brands) + 1,] = "MOL"
  }
  else if ((substr(company[2*number],1,6)) == "shell_") {
    brands[nrow(brands) + 1,] = "Shell"
  }
  else if ((substr(company[2*number],1,4)) == "omv_") {
    brands[nrow(brands) + 1,] = "OMV"
  }
  else if ((substr(company[2*number],1,7)) == "lukoil_") {
    brands[nrow(brands) + 1,] = "Orlen"
  }
  else if ((substr(company[2*number],1,5)) == "avia_") {
    brands[nrow(brands) + 1,] = "Avia"
  }
  else if ((substr(company[2*number],1,6)) == "mobil_") {
    brands[nrow(brands) + 1,] = "Mobil Petrol"
  }
  else if ((substr(company[2*number],1,4)) == "oil_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else if ((substr(company[2*number],1,5)) == "oil!_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else {
    brands[nrow(brands) + 1,] = "Other"
  }
}

#Using another soup, getting the location and prices.
mixed = page %>% html_nodes("td") %>% html_text()

#Cleaning attributes: first three and occasional "activebanner" attributes. Resulting soup of lines contain useful information periodically. Period of 4.
mixed <- mixed[4:length(mixed)]
num <- 1
mixed2 <- NULL
for (i in 1:length(mixed)){
  if (substring(mixed[i],1,14) == "activateBanner"){
    num <- num + 1
  }else {
    mixed2 <- append(mixed2,mixed[num])
    num <- num + 1
  }
}
soup <- mixed2[1:(4*nrow(brands))]
rm(num, mixed, mixed2)


#Extracting prices with one decimal.
comma_position <- 18
stop <- 0
while (stop == 0){
  comma_position <- comma_position + 1
  if (substring(soup[2],comma_position,comma_position) == "."){
    stop <- 1
  }
}

prices <- as.data.frame(as.numeric(substring(soup[2],18,comma_position + 1)))
colnames(prices) <- "price"

for (i in 2:nrow(brands)){
  comma_position <- 18
  stop <- 0
  while (stop == 0){
    comma_position <- comma_position + 1
    if (substring(soup[i*4-2],comma_position,comma_position) == "."){
      stop <- 1
    }
  }
  newdata <- as.data.frame(as.numeric(substring(soup[i*4-2],18,comma_position + 1)))
  colnames(newdata) <- "price"
  prices <- rbind(prices, newdata)
}

rm(comma_position, stop, newdata)

#Extracting the locations of the fuel stations using the soup.
locations <- as.data.frame(soup[3])
colnames(locations) <- "location"
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(soup[i*4-1])
  colnames(newdata) <- "location"
  locations <- rbind(locations, newdata)
}

#Creating the master dataframe with brand, price, location and time stamp.
date <- as.data.frame(Sys.Date())
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(Sys.Date())
  date <- rbind(date, newdata)
}
colnames(date) <- "date"
rm(newdata)

#Merging brand, price, location and date as well as indicating fuel type.
fuel <- cbind(brands, prices, locations, date)
fuel$petrol <- "premium diesel"

#Saving out results
current_date <- Sys.Date()
data_frame_name <- paste("premium_diesel_", current_date, sep = "")
assign(data_frame_name, fuel)
file_name <- paste('data/',data_frame_name, ".csv", sep = "")
write.csv(get(data_frame_name), file = file_name, fileEncoding = "UTF-8", row.names = FALSE)


# LPG

#repeating the whole procedure to obtain LPG prices.
rm(list=ls())

library(rvest)
library(tidyverse)
library(esquisse)
library(ggplot2)
library(openxlsx)

#creating the soup of company names and locations
link = paste0("https://holtankoljak.hu/index.php?ua_map=1&uz_tip=3&mycity=3338&myrad=500#tartalom"   , "")
page = read_html(link)
company = page %>% html_nodes("a") %>% html_attr('href')

#Cutting down the attributes in the beginning selected by error while determining the first appearing brand
num <- 0
stop <- 0
while (stop == 0) {
  num <- num + 1
  if ((substr(company[num],1,4)) == "mol_") {
    brand = "MOL"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "shell_") {
    brand = "Shell"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "omv_") {
    brand = "OMV"
    stop <- 1
  }
  else if ((substr(company[num],1,7)) == "lukoil_") {
    brand = "Orlen"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "avia_") {
    brand = "Avia"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "mobil_") {
    brand = "Mobil Petrol"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "oil_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,5)) == "oil!_") {
    brand = "Oil"
    stop <- 1
  }
  else if ((substr(company[num],1,4)) == "nkm-") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "auchan") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,6)) == "magan_") {
    brand = "Other"
    stop <- 1
  }
  else if ((substr(company[num],1,3)) == "nit") {
    brand = "Other"
    stop <- 1
  }
}

company <- company[num:length(company)]

#Cutting down the attributes in the end selected by error
num <- 0
stop <- 0

while (stop == 0){
  num <- num + 1
  if ((substr(company[num],1,5)) == "https"){
    stop <- 1
    endnumber <- num
  }
}

company <- company[1:(endnumber - 1)]
company <- company[1:(length(company)/2)]

rm(num)
rm(stop)

#Establishing a dataframe of the companies in order
brands <- data.frame(brand)

for (number in c(2:(length(company)/2))) {
  if ((substr(company[2*number],1,4)) == "mol_") {
    brands[nrow(brands) + 1,] = "MOL"
  }
  else if ((substr(company[2*number],1,6)) == "shell_") {
    brands[nrow(brands) + 1,] = "Shell"
  }
  else if ((substr(company[2*number],1,4)) == "omv_") {
    brands[nrow(brands) + 1,] = "OMV"
  }
  else if ((substr(company[2*number],1,7)) == "lukoil_") {
    brands[nrow(brands) + 1,] = "Orlen"
  }
  else if ((substr(company[2*number],1,5)) == "avia_") {
    brands[nrow(brands) + 1,] = "Avia"
  }
  else if ((substr(company[2*number],1,6)) == "mobil_") {
    brands[nrow(brands) + 1,] = "Mobil Petrol"
  }
  else if ((substr(company[2*number],1,4)) == "oil_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else if ((substr(company[2*number],1,5)) == "oil!_") {
    brands[nrow(brands) + 1,] = "Oil"
  }
  else {
    brands[nrow(brands) + 1,] = "Other"
  }
}

#Using another soup, getting the location and prices.
mixed = page %>% html_nodes("td") %>% html_text()

#Cleaning attributes: first three and occasional "activebanner" attributes. Resulting soup of lines contain useful information periodically. Period of 4.
mixed <- mixed[4:length(mixed)]
num <- 1
mixed2 <- NULL
for (i in 1:length(mixed)){
  if (substring(mixed[i],1,14) == "activateBanner"){
    num <- num + 1
  }else {
    mixed2 <- append(mixed2,mixed[num])
    num <- num + 1
  }
}
soup <- mixed2[1:(4*nrow(brands))]
rm(num, mixed, mixed2)


#Extracting prices with one decimal.
comma_position <- 6
stop <- 0
while (stop == 0){
  comma_position <- comma_position + 1
  if (substring(soup[2],comma_position,comma_position) == "."){
    stop <- 1
  }
}

prices <- as.data.frame(as.numeric(substring(soup[2],6,comma_position + 1)))
colnames(prices) <- "price"

for (i in 2:nrow(brands)){
  comma_position <- 6
  stop <- 0
  while (stop == 0){
    comma_position <- comma_position + 1
    if (substring(soup[i*4-2],comma_position,comma_position) == "."){
      stop <- 1
    }
  }
  newdata <- as.data.frame(as.numeric(substring(soup[i*4-2],6,comma_position + 1)))
  colnames(newdata) <- "price"
  prices <- rbind(prices, newdata)
}

rm(comma_position, stop, newdata)

#Extracting the locations of the fuel stations using the soup.
locations <- as.data.frame(soup[3])
colnames(locations) <- "location"
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(soup[i*4-1])
  colnames(newdata) <- "location"
  locations <- rbind(locations, newdata)
}

#Creating the master dataframe with brand, price, location and time stamp.
date <- as.data.frame(Sys.Date())
for (i in 2:nrow(brands)){
  newdata <- as.data.frame(Sys.Date())
  date <- rbind(date, newdata)
}
colnames(date) <- "date"
rm(newdata)

#Merging brand, price, location and date as well as indicating fuel type.
fuel <- cbind(brands, prices, locations, date)
fuel$petrol <- "lpg"

#Saving out results
current_date <- Sys.Date()
data_frame_name <- paste("lpg_", current_date, sep = "")
assign(data_frame_name, fuel)
file_name <- paste('data/',data_frame_name, ".csv", sep = "")
write.csv(get(data_frame_name), file = file_name, fileEncoding = "UTF-8", row.names = FALSE)

