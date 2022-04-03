# Set up output file ----------------------------------------------------------

# Store path to where we want to save data (look at the structure of your proj)

### 
savePath$ = "../data"
###

# Choose name for .csv file
outFile$ = "vowel_data.csv"

# Delete current file
filedelete 'savePath$'/'outFile$'

# Create file with headers
fileappend 'savePath$'/'outFile$' id,item,vowel,language,f1_cent,f2_cent,tl,
...f1_20,f1_35,f1_50,f1_65,f1_80,f2_20,f2_35,f2_50,f2_65,f2_80'newline$'

# -----------------------------------------------------------------------------





# Set up loop -----------------------------------------------------------------

# Set path to stim files (.wav and .TextGrid)

###
filePath$ = "../stim"
### 

# Get .wav file and store in list
Create Strings as file list... dirFiles 'filePath$'/*.wav

# Select .wav file and corresponding textgrid
select Strings dirFiles
fileName$ = Get string... 1
prefix$ = fileName$ - ".wav"
Read from file... 'filePath$'/'prefix$'.wav
Read from file... 'filePath$'/'prefix$'.TextGrid

# Check intervals
soundname$ = selected$ ("TextGrid", 1)
select TextGrid 'soundname$'
numberOfIntervals = Get number of intervals... 1
end_at = numberOfIntervals

# Set defaults
files = 0
intervalstart = 0
intervalend = 0
interval = 1
intnumber = 1 - 1
intname$ = ""
intervalfile$ = ""
endoffile = Get finishing time

for interval from 1 to end_at
    xxx$ = Get label of interval... 1 interval
    check = 0
    if xxx$ = ""
        check = 1
    endif
    if check = 0
       files = files + 1
    endif
endfor

interval = 1

# Add a string variable for your personal id, e.g., your initials
id$ = "gcd"


# -----------------------------------------------------------------------------




# Run loop --------------------------------------------------------------------

for interval from 1 to end_at
    select TextGrid 'soundname$'
    intname$ = ""
    intname$ = Get label of interval... 1 interval
    check = 0
    if intname$ = ""
        check = 1
    endif
    if check = 0
        intnumber = intnumber + 1
        intervalstart = Get starting point... 1 interval
            if intervalstart > 0.01
                intervalstart = intervalstart - 0.01
            else
                intervalstart = 0
            endif
    
        intervalend = Get end point... 1 interval
            if intervalend < endoffile - 0.01
                intervalend = intervalend + 0.01
            else
                intervalend = endoffile
            endif
        
        #
        # Get item and vowel labels
        #

        item$ = Get label of interval: 1, interval
        vowel$ = Get label of interval: 2, interval

        #
        # Get language label and time landmarks
        #

        Extract part... intervalstart intervalend rectangular 1 no
        language$ = Get label of point: 3, 1
        vonset = Get starting point: 2, 2
        voffset = Get end point: 2, 2
        durationV = voffset - vonset
        per20 = vonset + (durationV * 0.20)
        per35 = vonset + (durationV * 0.35)
        per50 = vonset + (durationV * 0.50)
        per65 = vonset + (durationV * 0.65)
        per80 = vonset + (durationV * 0.80)

        #
        # get formants
        #

        select Sound 'soundname$'
        Extract part... intervalstart intervalend rectangular 1 no
        do ("To Formant (burg)...", 0, 5, 4800, 0.025, 30)
        f1_20 = do ("Get value at time...", 1, per20, "Hertz", "Linear")
        f1_35 = do ("Get value at time...", 1, per35, "Hertz", "Linear")
        f1_50 = do ("Get value at time...", 1, per50, "Hertz", "Linear")    
        f1_65 = do ("Get value at time...", 1, per65, "Hertz", "Linear")
        f1_80 = do ("Get value at time...", 1, per80, "Hertz", "Linear")
        f2_20 = do ("Get value at time...", 2, per20, "Hertz", "Linear")
        f2_35 = do ("Get value at time...", 2, per35, "Hertz", "Linear")
        f2_50 = do ("Get value at time...", 2, per50, "Hertz", "Linear")    
        f2_65 = do ("Get value at time...", 2, per65, "Hertz", "Linear")
        f2_80 = do ("Get value at time...", 2, per80, "Hertz", "Linear")

        # Calculate spectral centroids and trajectory length
        f1_cent = (f1_20 + f1_35 + f1_50 + f1_65 + f1_80)/5
        f2_cent = (f2_20 + f2_35 + f2_50 + f2_65 + f2_80)/5

        vsl1 = sqrt((f1_20 - f1_35)^2 + (f2_20 - f2_35)^2)
        vsl2 = sqrt((f1_35 - f1_50)^2 + (f2_35 - f2_50)^2)
        vsl3 = sqrt((f1_50 - f1_65)^2 + (f2_50 - f2_65)^2)
        vsl4 = sqrt((f1_65 - f1_80)^2 + (f2_65 - f2_80)^2)
        tl = vsl1 + vsl2 + vsl3 + vsl4

        selectObject: "Sound stim_part"
        plusObject: "TextGrid stim_part"
        plusObject: "Formant stim_part"
        Remove

        # Print results to window and save to .csv file
        printline 'id$','item$','vowel$','language$','f1_cent:2','f2_cent:2','tl:2'
        fileappend 'savePath$'/'outFile$' 'id$','item$','vowel$','language$',
        ...'f1_cent:2','f2_cent:2','tl:2','f1_20:2','f1_35:2','f1_50:2','f1_65:2',
        ...'f1_80:2','f2_20:2','f2_35:2','f2_50:2','f2_65:2','f2_80:2''newline$'

    endif

endfor

# Remove objects from praat menu
select all
Remove

# -----------------------------------------------------------------------------