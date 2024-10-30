/* Generated Code (IMPORT) */
/* Source File: Med_Apt.csv */
/* Source Path: /home/u63591817/sasuser.v94/Medical Appointment Data */
/* Code generated on: 9/15/23, 8:25 PM */

%web_drop_table(WORK.IMPORT);


FILENAME REFFILE '/home/u63591817/sasuser.v94/Medical Appointment Data/Med_Apt.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;


%web_open_table(WORK.IMPORT);

proc import datafile='/home/u63591817/sasuser.v94/Medical Appointment Data/Med_Apt.csv' dbms=csv 
out=EDA_PROJECT;
run;

Proc contents data=eda_project varnum;
run;

proc means data=eda_project;
run;

proc means data=eda_project nmiss;
run;

data apt_data1 (rename=('No-Show'n = Show));
set eda_project;
label 'No-Show'n='Show';
run;

data apt_data2;
set apt_data1;
if show = 'No' then Show = 1;
else if show = 'Yes' then Show = 0;
run;

/*to check the names of the variables*/

proc print data=apt_data1 (obs=5);
run;

data EDA (drop=patientid appointmentid);
set apt_data2 (rename=(Hipertension=Hypertension));
drop scheduledday appointmentday;
Schld_date = datepart(scheduledday);
Apt_date = datepart(Appointmentday);
format schld_date apt_date date9.;
day_diff = (apt_date - schld_date);
run;

Proc contents data=eda;
Run;

ods graphics on;
proc freq data=work.eda;
tables show/ nocum plots=freqplot(type=bar scale=percent);
run;
ods graphics off;

ods graphics on;
proc freq data=eda;
tables show*gender/ plots=freqplot(twoway=stacked orient=Horizontal);
run;
ods graphics off;

ods graphics on;
proc freq data=eda;
tables show*scholarship/ plots=freqplot(twoway=stacked orient=vertical);
run;
ods graphics off;

ods graphics on;
proc freq data=eda;
Tables show*hypertension/ plots=freqplot(twoway=stacked orient=Horizontal);
run;
ods graphics off;


ods graphics on;
proc freq data=eda;
tables show*sms_received/ plots=freqplot(twoway=stacked orient=Horizontal);
run;
ods graphics off;

data day_cat;
set eda;
length apt_name $ 16;
if day_diff <= 0 then day_diff2 = 'Same Day';
else if day_diff <= 4 then day_diff2 = 'Few Days';
else if day_diff > 4 and day_diff <= 15 then day_diff2 = 'More than 4';
else day_diff2 = 'More than 15';
run;

proc freq data=day_cat;
tables day_diff2/nocum;
run;

ods graphics on;
proc freq data=day_cat;
tables show*day_diff2 /plots=freqplot(twoway=grouphorizontal orient=vertical);
run;
ods graphics off;

proc univariate data=eda;
    class show;
    var age ;
    histogram age/ overlay;
run;

data No_Show;
set eda;
if show = 0;
run;
ods graphics / reset width=14in height=6in imagemap;

proc sgplot data=WORK.NO_SHOW;
 vbar Neighbourhood / group=Show groupdisplay=cluster 
  fillattrs=(transparency=0.25) datalabelfitpolicy=none;
 yaxis grid;
 refline 508 / axis=y lineattrs=(thickness=2 color=Red) label 
  labelattrs=(color=Red);
 keylegend / location=inside;
run;

ods graphics / reset;

/* After Changing the name of variable 'No-show' to 'Show' and changing the
 label from No-Show to Show */
data apt_data1 (rename=('No-Show'n = Show));
set eda_project;
label 'No-Show'n='Show';
run;

/* Invered No-Show - > Show values with integer values  */

data apt_data2;
set apt_data1;
if show = 'No' then Show = 1;
else if show = 'Yes' then Show = 0;
run;

/*7. Getting the date only part out of datetime values of scheduledday and 
appointmentday in data  */
/* Create a new column for difference between scheduling and appointment */

data EDA (drop=patientid appointmentid);
set apt_data2 (rename=(Hipertension=Hypertension));
drop scheduledday appointmentday;
Schld_date = datepart(scheduledday); 
Apt_date = datepart(Appointmentday); 
format schld_date apt_date date9.; 
day_diff = (apt_date - schld_date);
run;

/*7. After changing the dataset by steps mentioned above, I changed the date
to weekday to checon which dates the patients missed most of their 
appointments, 
I also changed the numeric weekdays to weekday names using if then statement*/

data weekdays;
set eda;
apt_day =weekday(apt_date);
if apt_day = 1 then week_day = 'Sun';
else if apt_day = 2 then week_day = 'Mon';
else if apt_day = 3 then week_day = 'Tues';
else if apt_day = 4 then week_day = 'Wednes';
else if apt_day = 5 then week_day = 'Thurs';
else if apt_day = 6 then week_day = 'Fri';
else week_day = 'Satr';
run;

*/Bar char*/

title "Weekdays On Which Most of the Appointments Were Missed ";
proc sgplot data = weekdays;
    vbar week_day/ group=show groupdisplay=cluster stat=freq  ;
run;