#!/bin/bash

# "error.log is a file for storing all errors and not appering infornt of the user"
mkdir DBMS 2>> ./.error.log

clear 
echo "----------------------------------------------------"
echo -e "Database Management System using shell scrpiting"
echo "----------------------------------------------------"

function main_menu {
    echo -e "\nMain Menu\n"
    echo "1. Connect DB"
    echo "2. Create DB"
    echo "3. Rename DB"
    echo "4. Drop DB"
    echo "5. List DBs"
    echo "6. Quit"

    echo -e "\nChoice : \c\n"
    read input
    case $input in 
    1) clear ; connectDB ;;
    2) clear ;createDB ;;
    3) clear ;renameDB ;;
    4) clear ;dropDB ;;
    5) ls ./DBMS; main_menu ;;
    6) exit;;
    *) echo "Invalid Option. Please Try Again "; main_menu;;
    esac

}


function connectDB {
  # enter a database name
  echo -e "Database Name : \c"

  # Read user input and save to variable "dbName"
  read dbName

  # Change current directory to "./DBMS/$dbName", redirecting any error messages to "./.error.log"
  cd ./DBMS/$dbName 2>>./.error.log
  
  # Check if "cd" command succeeded or failed
  if [[ $? == 0 ]]; then
    # If "cd" command succeeded, print success message and call "tablesMenu" function
    echo "Database $dbName Connected"
    tablesMenu
  else
    # If "cd" command failed, print error message and call "mainMenu" function
    echo "Database $dbName wasn't found"
    main_menu
  fi
}

function createDB {
  echo -e "Database Name : \c"
  # Read user input and save to variable "dbName"
  read dbName
  # Create a new directory named after the database in the "DBMS" directory
  mkdir ./DBMS/$dbName
  # Check if "mkdir" command succeeded or failed
  if [[ $? == 0 ]]
  then
    # If "mkdir" command succeeded, print success message
    echo "Database Created"
  else
    # If "mkdir" command failed, print error message
    echo "Error Creating Database $dbName"
  fi
  # Go back to the main menu
  main_menu
}

function renameDB {
 
  echo -e "Database Name : \c"
  # Read user input and save to variable "dbName"
  read dbName

  # enter the new database name
  echo -e "New Database Name: \c"
  # Read user input and save to variable "newName"
  read newName

  # Rename the directory named after the current database to the new name
  mv ./DBMS/$dbName ./DBMS/$newName 2>>./.error.log

  # Check if "mv" command succeeded or failed
  if [[ $? == 0 ]]; then
    # If "mv" command succeeded, print success message
    echo "Database Renamed"
  else
    # If "mv" command failed, print error message
    echo "Error Renaming Database"
  fi
  # Go back to the main menu
  main_menu
}

function dropDB {
 
  echo -e "Enter Database Name: \c"
  # Read user input and save to variable "dbName"
  read dbName
  # Remove the directory named after the database from the "DBMS" directory
  rm -r ./DBMS/$dbName 2>>./.error.log
  # Check if "rm" command succeeded or failed
  if [[ $? == 0 ]]; then
    # If "rm" command succeeded, print success message
    echo "Database Dropped Successfully"
  else
    # If "rm" command failed, print error message
    echo "Database Not found"
  fi
  # Go back to the main menu
  main_menu
}

function tablesMenu {

  echo -e "\nTable Menu\n"
  echo "1. List Tables"
  echo "2. Select Records From Table"
  echo "3. Create New Table"
  echo "4. Insert Record Into Table"
  echo "5. Update Record From Table"
  echo "6. Delete Record From Table"
  echo "7. Delete Table"
  echo "8. Back To Main Menu"   
  echo "9. Quit"
  echo -e "\nChoice: \c\n"
  read ch
  case $ch in
    1)  ls .; tablesMenu ;;
    2)  clear; selectMenu ;;
    3)  createTable;;
    4)  insertRecord;;
    5)  updateRecord;;
    6)  deleteFromTable;;
    7)  dropTable;;
    8) clear; cd ../..; main_menu ;;
    9) exit ;;
    *) echo "Invalid Option. Please Try Again" ; tablesMenu;
  esac

}

function createTable {
  # enter a table name
  echo -e "Table Name: \c"
  read tableName

  # Check if a file with the given table name already exists
  if [[ -f $tableName ]]; then
    echo "Table already exists. Please choose another name."
    tablesMenu
  fi

  #enter the number of columns for the table
  echo -e "Number of Columns: \c"
  read cols

  # Initialize variables for metadata and table data
  i=1
  sep="|"      # Separator character for table data
  pKey=""      # Primary key column name (if any)
  metaData="Field"$sep"Type"$sep"Key"   # Table metadata header
  header=""      # String for  table data header

  # Loop over each column and prompt user for column name, type, and Pkey 
  while [ $i -le $cols ]
  do
    # Prompt user to enter the name of the current column
    echo -e "Name of Column $i: \c"
    read colName

    # Prompt user to select the type of the current column (int or str)
    echo -e "Type of Column $i: "
    select var in "int" "str"
    do
      case $var in
        int ) colType="int";break;;
        str ) colType="str";break;;
        * ) echo "Wrong Choice" ;;
      esac
    done

    # If a primary key column has not yet been selected, prompt user to select one
    if [[ $pKey == "" ]]; then
      echo -e "Make $i Primary Key? "
      select var in "yes" "no"
      do
        case $var in
          yes ) pKey="PK";
          metaData+="\n"$colName$sep$colType$sep$pKey;   # Add column metadata to table metadata with "PK" flag
          break;;
          no )
          metaData+="\n"$colName$sep$colType$sep""       # Add column metadata to table metadata without "PK" flag
          break;;
          * ) echo "Wrong Choice" ;;
        esac
      done
    else
      metaData+="\n"$colName$sep$colType$sep""           # Add column metadata to table metadata without "PK" flag
    fi

    # Add current column name to table data header string, with separator if not the last column
    if [[ $i == $cols ]]; then
      temp=$temp$colName
    else
      temp=$temp$colName$sep
    fi
    
    # Increment counter for next iteration of loop
    ((i++))
  done

  # Create two new files: one for table metadata and one for table data
  touch .$tableName                  # Hidden file for table metadata
  echo -e $metaData  >> .$tableName   # Write table metadata to hidden file
  touch $tableName                   # Visible file for table data
  echo -e $header >> $tableName         # Write table data header to visible file

  # Check if table creation succeeded or failed, and print appropriate message
  if [[ $? == 0 ]]
  then
    echo "Table Created Successfully"
    tablesMenu
  else
    echo "Error Creating Table $tableName"
    tablesMenu
  fi
}

function insertRecord {
  # Prompt user to enter the name of the table to insert data into
  echo -e "Table Name: \c"
  read tableName

  # Check if the table exists
  if ! [[ -f $tableName ]]; then
    echo "Table $tableName does not exist. Please choose another table."
    tablesMenu
  fi

  # Get the number of columns in the table from the metadata file
  cols=`awk 'END{print NR}' .$tableName`

  # Initialize variables for constructing the row to insert
  sep="|"      # Separator character for row data
  row=""

  # Loop over each column in the table and prompt user to enter data for each column
  for (( i = 2; i <= $cols; i++ )); do
    # Get column name, type, and Pkey status from the metadata file
    Name=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tableName)
    Type=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tableName)
    Key=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $3}' .$tableName)

    # Prompt user to enter data for the current column
    echo -e "$Name ($Type) = \c"
    read data

    # Validate input based on column type (int)
    if [[ $Type == "int" ]]; then
      while ! [[ $data =~ ^[0-9]*$ ]]; do
        echo -e "Invalid data type. Please enter an integer value."
        echo -e "$Name ($Type) = \c"
        read data
      done
    fi

    # Validate input based on primary key status
    if [[ $Key == "PK" ]]; then
      while [[ true ]]; do
        # Check if the entered data matches any existing primary key values in the table
        if [[ $data =~ ^[`awk 'BEGIN{FS="|" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tableName`]$ ]]; then
          echo -e "Invalid input for primary key. Please enter a unique value."
        else
          break;
        fi
        echo -e "$Name ($Type) = \c"
        read data
      done
    fi

    # Add current column data to the row string, with separator if not the last column
    if [[ $i == $cols ]]; then
      row=$row$data"\n" 
    else
      row=$row$data$sep
    fi
  done

  # Write the completed row string to the table data file
  echo -e $row"\c" >> $tableName

  # Check if data insertion succeeded or failed, and print message
  if [[ $? == 0 ]]
  then
    echo "Data Inserted Successfully"
  else
    echo "Error Inserting Data into Table $tableName"
  fi

  # Reset row string and return to the tables menu
  row=""
  tablesMenu
}

function updateRecord {

  echo -e "Enter Table Name: \c"
  # Read table name from user input
  read tName
  # Prompt user to enter condition column name
  echo -e "Enter Condition Column name: \c"
  # Read condition column name from user input
  read column
  # Use awk command to find the index of the condition column in the table
  # The awk command searches for the column name in the first row of the table
  # and prints the index of the column if found
  index=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$column'") print i}}}' $tName)
  # If the condition column is not found in the table, print an error message
  # and go back to the tables menu
  if [[ $index == "" ]]
  then
    echo "Not Found"
    tablesMenu
  else
    echo -e "Enter Condition Value: \c"
    # Read condition value from user input
    read value
    # Use awk command to find rows in the table where the condition column has the
    # same value as the user input
    # The awk command prints the value of the condition column for any matching rows
    result=$(awk 'BEGIN{FS="|"}{if ($'$index'=="'$value'") print $'$index'}' $tName 2>>./.error.log)
    # If no rows match the condition, print an error message and go back to the tables menu
    if [[ $result == "" ]]
    then
      echo "Value Not Found"
      tablesMenu
    else
      # Prompt user to enter the name of the column to update
      echo -e "Enter Column name to update: \c"
      # Read the column name to update from user input
      read setColumn
      # Use awk command to find the index of the column to update in the table
      # The awk command searches for the column name in the first row of the table
      # and prints the index of the column if found
      index2=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$setColumn'") print i}}}' $tName)
      # If the column to update is not found in the table, print an error message
      # and go back to the tables menu
      if [[ $index2 == "" ]]
      then
        echo "Not Found"
        tablesMenu
      else
        echo -e "Enter new Value to update: \c"
        # Read the new value from user input
        read newValue
        # Use awk command to find the row number of the first row that matches the condition
        NR=$(awk 'BEGIN{FS="|"}{if ($'$index' == "'$value'") print NR}' $tName 2>>./.error.log)
        # Use awk command to find the old value of the column in the row that matches the condition
        # The awk command prints the value of the column for the row number found in the previous step
        oldValue=$(awk 'BEGIN{FS="|"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$index2') print $i}}}' $tName 2>>./.error.log)
        # Use sed command to replace the old value of the column with the new value in the row that matches the condition
        sed -i ''$NR's/'$oldValue'/'$newValue'/g' $tName 2>>./.error.log
        # Print a success message
        echo "Row Updated Successfully"
        # Go back to the tables menu
        tablesMenu
      fi
    fi
  fi
}

function deleteFromTable {
  
  echo -e "Enter Table Name: \c"
  # Read table name from user input
  read tName
  # Prompt user to enter condition column name
  echo -e "Enter Condition Column name: \c"
  # Read condition column name from user input
  read column
  # Use awk command to find the index of the condition column in the table
  # The awk command searches for the column name in the first row of the table
  # and prints the index of the column if found
  index=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$column'") print i}}}' $tName)
  # If the condition column is not found in the table, print an error message
  # and go back to the tables menu
  if [[ $index == "" ]]
  then
    echo "Not Found"
    tablesMenu
  else
    # Prompt user to enter condition value
    echo -e "Enter Condition Value: \c"
    # Read condition value from user input
    read value
    # Use awk command to find rows in the table where the condition column has the
    # same value as the user input
    # The awk command prints the value of the condition column for any matching rows
    result=$(awk 'BEGIN{FS="|"}{if ($'$index'=="'$value'") print $'$index'}' $tName 2>>./.error.log)
    # If no rows match the condition, print an error message and go back to the tables menu
    if [[ $result == "" ]]
    then
      echo "Value Not Found"
      tablesMenu
    else
      # Use awk command to find the row number(s) of the rows that match the condition
      # The awk command prints the row numbers where the condition is true
      NR=$(awk 'BEGIN{FS="|"}{if ($'$index'=="'$value'") print NR}' $tName 2>>./.error.log)
      # Use sed command to delete the row(s) that match the condition
      # The sed command deletes the row number(s) found in the previous step
      sed -i ''$NR'd' $tName 2>>./.error.log
      # Print a success message
      echo "Row Deleted Successfully"
      # Go back to the tables menu
      tablesMenu
    fi
  fi
}

function dropTable {
  echo -e "Enter Table Name: \c"
  # Read table name from user input
  read tName
  #rm command to delete the table file and its corresponding error log file
  rm $tName .$tName 2>>./.error.log
  # If the rm command is successfully executed, print a success message
  if [[ $? == 0 ]]
  then
    echo "Table Dropped Successfully"
  # If the rm command fails, print an error message
  else
    echo "Error Dropping Table $tName"
  fi
  # Go back to the tables menu
  tablesMenu
}

function selectMenu {
  echo -e "\nSelect Menu\n"
  echo "1. Select All Columns of a Table"
  echo "2. Select Specific Column from a Table"
  echo "3. Back To Tables Menu"
  echo "4. Back To Main Menu"
  echo "5. Quit"
  echo -e "\nEnter Choice: \c"
  read ch
  case $ch in
    1) clear;selectAll ;;
    2) clear;selectCol ;;
    3) clear; tablesMenu ;;
    4) clear; cd ../.. ; main_menu ;;
    5) exit ;;
    *) echo "Invalid Option. Please Try Again" ; selectMenu;
  esac
}

function selectAll {

  echo -e "Enter Table Name: \c"
  # Read table name from user input
  read tName
  # Use the column command to display the table in a formatted manner
  # The '-t' flag specifies that the input is a table with '|' as a separator
  # The '-s' flag specifies the separator to use when formatting the output
  # The column command formats the table in a columnar manner
  # Any error messages are appended to a log file named '.error.log'
  column -t -s '|' $tName 2>>./.error.log
  # If the column command fails, print an error message
  if [[ $? != 0 ]]
  then
    echo "Error Displaying Table $tName"
  fi
  # Go back to the select menu
  selectMenu
}

function selectCol {

  echo -e "Enter Table Name: \c"
  # Read table name from user input
  read tName
  # Prompt user to enter column number
  echo -e "Enter Column Number: \c"
  # Read column number from user input
  read colNum
  # Use awk command to print the specified column of the table
  # The awk command uses the '|' separator and prints only the column specified by the user
  awk 'BEGIN{FS="|"}{print $'$colNum'}' $tName
  # Go back to the select menu
  selectMenu
}

 
main_menu

