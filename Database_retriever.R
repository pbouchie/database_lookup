# Section 1 - Packages ####

list.of.packages <- c("tidyverse", "writexl", "readxl")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages) > 0){
    install.packages(new.packages)
}

lapply(list.of.packages, library, character.only = TRUE)


# Section 2 - Read in Excel files ####

FilePath <- grep(list.files(path = "L:\\(insert filepath here)/", full.names = T), pattern = "SUVD", ignore.case = T, value = T)
FilePath <- FilePath[which.max(file.mtime(FilePath))]                

Database <- read_excel(path = FilePath, sheet = "DNA")

print ("Database file was retrieved from: ", FilePath)

# Read in Constructs 

Constructs <- read_excel(path = "Construct_input.xlsx")


# Section 3 - Data Cleaning #### 

#Remove lines that are empty (NA)
Constructs <- na.omit(Constructs)


# Section 4 - Data processing ####

#Join chosen construct Ids with information from the database
Results <- full_join(Constructs, Database[grep(paste(Constructs$`ID#`,collapse="|"), Database$`ID#`),])
Results <- Results %>% group_by(`ID#`) 
            %>% mutate( "n" = row_number()) 
            %>% select(`Index`, `ID#`, `DNA Lot#`, `DNA Storage: Drawer, Box, Position`,n, everything())

#Initialize a summary
Summary <- list()
#Add results to summary
Summary[[1]] <- Results
#Document date, version and database version
DataType <- c("Date of Analysis", "R Version", "DatabaseVersion")
DataSource <- c(as.character(Sys.Date()), R.version.string, basename(FilePath))
Summary[[2]] <- data.frame(`DataType`, `DataSource`)


# Section 5 - Write the data outcome ####
write_xlsx(Summary,"Constructs_output.xlsx")
print ("Script has finished running")