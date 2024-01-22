%MACRO ODSon();
ODS GRAPHICS ON;
ODS RESULTS ON;
ODS EXCLUDE NONE;
%MEND;

%MACRO ODSoff();
ODS GRAPHICS OFF; 
ODS RESULTS OFF; 
ODS EXCLUDE ALL;
%MEND;

/* DATA */

/* All 3 datasets are ordered according to the cluster structure i.e. ITTER107, AgeGroup and TIME */

/* Men */
PROC IMPORT FILE="C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\male.csv"
OUT=MALE DBMS=CSV REPLACE; /* SHEET= importo uno specifico foglio del file excel */
RUN;

/* Women */
PROC IMPORT FILE="C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\female.csv"
OUT=FEMALE DBMS=CSV REPLACE; /* SHEET= importo uno specifico foglio del file excel */
RUN;

/* Men in small municipalities */
PROC IMPORT FILE="C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\piccoli_comuni_male.csv"
OUT=PICCOLI_COMUNI_MALE DBMS=CSV REPLACE; /* SHEET= importo uno specifico foglio del file excel */
RUN;

/* Women in small municipalities */
PROC IMPORT FILE="C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\piccoli_comuni_female.csv"
OUT=PICCOLI_COMUNI_FEMALE DBMS=CSV REPLACE; /* SHEET= importo uno specifico foglio del file excel */
RUN;

/* MODELS */

/* Model implementation for SII estimates of educational rank with categorical time variable
for the female gender */

%ODSoff;
*ODS TRACE ON;
PROC GENMOD DATA=FEMALE;
CLASS ITTER107 AGEGROUP TIME / PARAM=GLM;
MODEL DECESSI = POP_MEDIA*AGEGROUP POP_MEDIA*EDUC_RANK*TIME / DIST=POISSON LINK=IDENTITY SCALE=PEARSON NOINT;
REPEATED SUBJECT=ITTER107*AGEGROUP / TYPE=AR(1);
ods output GEEEmpPEst=educSII_female_GEE;
RUN;
*ODS TRACE OFF;
%ODSon;

/* We save coefficients estimates */

DATA educSII_female_GEE;
SET educSII_female_GEE;
FORMAT Estimate Stderr LowerCL UpperCL BestD16.; /* set format for variables */
RUN;

PROC EXPORT DATA=educSII_female_GEE
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\educSII_female_GEE.csv' DBMS=CSV REPLACE;
RUN;

/* SENSITIVITY ANALYSIS - SII */

/* MEN - EDUC */

/* 1) Model implementation for SII estimates of education rank with time variable 
as categorical variable for male gender in small municipalities */

%ODSoff;
PROC GENMOD DATA=PICCOLI_COMUNI_MALE;
CLASS ITTER107 AGEGROUP TIME / PARAM=GLM;
MODEL DECESSI = POP_MEDIA*AGEGROUP POP_MEDIA*EDUC_RANK*TIME / DIST=POISSON LINK=IDENTITY SCALE=PEARSON NOINT;
REPEATED SUBJECT=ITTER107*AGEGROUP / TYPE=AR(1);
ods output GEEEmpPEst=educSII_male_GEE_piccoli;
RUN;
%ODSon;

/* We save coefficients estimates */

DATA educSII_male_GEE_piccoli;
SET educSII_male_GEE_piccoli;
FORMAT Estimate Stderr LowerCL UpperCL BestD16.; 
RUN;

PROC EXPORT DATA=educSII_male_GEE_piccoli
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\educSII_male_GEE_piccoli.csv' DBMS=CSV REPLACE;
RUN;

/* 2) Model implementation for SII estimates of education rank with time variable 
as continuous variable for male gender in small municipalities */

%ODSoff;
PROC GENMOD DATA=PICCOLI_COMUNI_MALE;
CLASS ITTER107 AGEGROUP / PARAM=GLM;
MODEL DECESSI = POP_MEDIA*AGEGROUP POP_MEDIA*EDUC_RANK POP_MEDIA*EDUC_RANK*TIME1 / DIST=POISSON LINK=IDENTITY SCALE=PEARSON NOINT;
REPEATED SUBJECT=ITTER107*AGEGROUP / TYPE=AR(1) ECOVB;
ods output GEEEmpPEst=educSII_male_GEE_piccoli2;
ods output GEERCov=educSII_male_GEE_piccoli_vcov2;
RUN;
%ODSon;

/* We save coefficients estimates and covariance matrix */

DATA educSII_male_GEE_piccoli2;
SET educSII_male_GEE_piccoli2;
FORMAT Estimate Stderr LowerCL UpperCL BestD16.; 
RUN;

PROC EXPORT DATA=educSII_male_GEE_piccoli2
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\educSII_male_GEE_piccoli2.csv' DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA=educSII_male_GEE_piccoli_vcov2
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\educSII_male_GEE_piccoli_vcov2.csv' DBMS=CSV REPLACE;
RUN;

/* 3) Model implementation for SII estimates of education rank with time variable 
as continuous variable for male gender in small municipalities, excluding the calendar years 2020, 2021 and 2022 */

DATA PICCOLI_COMUNI_MALE_PRECOVID;
SET PICCOLI_COMUNI_MALE;
IF TIME NE 2020 AND TIME NE 2021 AND TIME NE 2022 THEN OUTPUT;
RUN;

%ODSoff;
PROC GENMOD DATA=PICCOLI_COMUNI_MALE_PRECOVID;
CLASS ITTER107 AGEGROUP / PARAM=GLM;
MODEL DECESSI = POP_MEDIA*AGEGROUP POP_MEDIA*EDUC_RANK POP_MEDIA*EDUC_RANK*TIME1 / DIST=POISSON LINK=IDENTITY SCALE=PEARSON NOINT;
REPEATED SUBJECT=ITTER107*AGEGROUP / TYPE=AR(1) ECOVB;
ODS OUTPUT GEEEmpPEst=educSII_male_GEE_piccoli3;
ODS OUTPUT GEERCov=educSII_male_GEE_piccoli_vcov3;
RUN;
%ODSon;

/* We save coefficients estimates and covariance matrix */

DATA educSII_male_GEE_piccoli3;
SET educSII_male_GEE_piccoli3;
FORMAT Estimate Stderr LowerCL UpperCL BestD16.; 
RUN;

PROC EXPORT DATA=educSII_male_GEE_piccoli3
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\educSII_male_GEE_piccoli3.csv' DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA=educSII_male_GEE_piccoli_vcov3
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\educSII_male_GEE_piccoli_vcov3.csv' DBMS=CSV REPLACE;
RUN;

/* MEN - INCOME */

/* 1) Model implementation for SII estimates of income rank with time variable 
as categorical variable for male gender in small municipalities */

%ODSoff;
PROC GENMOD DATA=PICCOLI_COMUNI_MALE;
CLASS ITTER107 AGEGROUP TIME / PARAM=GLM;
MODEL DECESSI = POP_MEDIA*AGEGROUP POP_MEDIA*INCOME_RANK*TIME / DIST=POISSON LINK=IDENTITY SCALE=PEARSON NOINT;
REPEATED SUBJECT=ITTER107*AGEGROUP / TYPE=AR(1);
ods output GEEEmpPEst=incomeSII_male_GEE_piccoli;
RUN;
%ODSon;

/* We save coefficients estimates */

DATA incomeSII_male_GEE_piccoli;
SET incomeSII_male_GEE_piccoli;
FORMAT Estimate Stderr LowerCL UpperCL BestD16.; 
RUN;

PROC EXPORT DATA=incomeSII_male_GEE_piccoli
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\incomeSII_male_GEE_piccoli.csv' DBMS=CSV REPLACE;
RUN;

/* 2) Model implementation for SII estimates of income rank with time variable 
as continuous variable for male gender in small municipalities */

%ODSoff;
PROC GENMOD DATA=PICCOLI_COMUNI_MALE;
CLASS ITTER107 AGEGROUP / PARAM=GLM;
MODEL DECESSI = POP_MEDIA*AGEGROUP POP_MEDIA*INCOME_RANK POP_MEDIA*INCOME_RANK*TIME1 / DIST=POISSON LINK=IDENTITY SCALE=PEARSON NOINT;
REPEATED SUBJECT=ITTER107*AGEGROUP / TYPE=AR(1) ECOVB;
ODS OUTPUT GEEEmpPEst=incomeSII_male_GEE_piccoli2;
ODS OUTPUT GEERCov=incomeSII_male_GEE_piccoli_vcov2;
RUN;
%ODSon;

/* We save coefficients estimates and covariance matrix */

DATA incomeSII_male_GEE_piccoli2;
SET incomeSII_male_GEE_piccoli2;
FORMAT Estimate Stderr LowerCL UpperCL BestD16.; 
RUN;

PROC EXPORT DATA=incomeSII_male_GEE_piccoli2
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\incomeSII_male_GEE_piccoli2.csv' DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA=incomeSII_male_GEE_piccoli_vcov2
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\incomeSII_male_GEE_piccoli_vcov2.csv' DBMS=CSV REPLACE;
RUN;

/* 3) Model implementation for SII estimates of income rank with time variable 
as continuous variable for male gender in small municipalities, excluding the calendar years 2020, 2021 and 2022 */

%ODSoff;
PROC GENMOD DATA=PICCOLI_COMUNI_MALE_PRECOVID;
CLASS ITTER107 AGEGROUP / PARAM=GLM;
MODEL DECESSI = POP_MEDIA*AGEGROUP POP_MEDIA*INCOME_RANK POP_MEDIA*INCOME_RANK*TIME1 / DIST=POISSON LINK=IDENTITY SCALE=PEARSON NOINT;
REPEATED SUBJECT=ITTER107*AGEGROUP / TYPE=AR(1) ECOVB;
ODS OUTPUT GEEEmpPEst=incomeSII_male_GEE_piccoli3;
ODS OUTPUT GEERCov=incomeSII_male_GEE_piccoli_vcov3;
RUN;
%ODSon;

/* We save coefficients estimates and covariance matrix */

DATA incomeSII_male_GEE_piccoli3;
SET incomeSII_male_GEE_piccoli3;
FORMAT Estimate Stderr LowerCL UpperCL BestD16.; 
RUN;

PROC EXPORT DATA=incomeSII_male_GEE_piccoli3
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\incomeSII_male_GEE_piccoli3.csv' DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA=incomeSII_male_GEE_piccoli_vcov3
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\incomeSII_male_GEE_piccoli_vcov3.csv' DBMS=CSV REPLACE;
RUN;

/* WOMEN - EDUC */

/* 1) Model implementation for SII estimates of education rank with time variable 
as categorical variable for female gender in small municipalities */

%ODSoff;
PROC GENMOD DATA=PICCOLI_COMUNI_FEMALE;
CLASS ITTER107 AGEGROUP TIME / PARAM=GLM;
MODEL DECESSI = POP_MEDIA*AGEGROUP POP_MEDIA*EDUC_RANK*TIME / DIST=POISSON LINK=IDENTITY SCALE=PEARSON NOINT;
REPEATED SUBJECT=ITTER107*AGEGROUP / TYPE=AR(1);
ods output GEEEmpPEst=educSII_female_GEE_piccoli;
RUN;
%ODSon;

/* We save coefficients estimates */

DATA educSII_female_GEE_piccoli;
SET educSII_female_GEE_piccoli;
FORMAT Estimate Stderr LowerCL UpperCL BestD16.; 
RUN;

PROC EXPORT DATA=educSII_female_GEE_piccoli
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\educSII_female_GEE_piccoli.csv' DBMS=CSV REPLACE;
RUN;

/* 2) Model implementation for SII estimates of education rank with time variable 
as continuous variable for female gender in small municipalities */

%ODSoff;
PROC GENMOD DATA=PICCOLI_COMUNI_FEMALE;
CLASS ITTER107 AGEGROUP / PARAM=GLM;
MODEL DECESSI = POP_MEDIA*AGEGROUP POP_MEDIA*EDUC_RANK POP_MEDIA*EDUC_RANK*TIME1 / DIST=POISSON LINK=IDENTITY SCALE=PEARSON NOINT;
REPEATED SUBJECT=ITTER107*AGEGROUP / TYPE=AR(1) ECOVB;
ODS OUTPUT GEEEmpPEst=educSII_female_GEE_piccoli2;
ODS OUTPUT GEERCov=educSII_female_GEE_piccoli_vcov2;
RUN;
%ODSon;

DATA educSII_female_GEE_piccoli2;
SET educSII_female_GEE_piccoli2;
FORMAT Estimate Stderr LowerCL UpperCL BestD16.; 
RUN;

/* We save coefficients estimates and covariance matrix */

PROC EXPORT DATA=educSII_female_GEE_piccoli2
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\educSII_female_GEE_piccoli2.csv' DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA=educSII_female_GEE_piccoli_vcov2
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\educSII_female_GEE_piccoli_vcov2.csv' DBMS=CSV REPLACE;
RUN;

/* 3) Model implementation for SII estimates of education rank with time variable 
as continuous variable for female gender in small municipalities, excluding the calendar years 2020, 2021 and 2022 */

DATA PICCOLI_COMUNI_FEMALE_PRECOVID;
SET PICCOLI_COMUNI_FEMALE;
IF TIME NE 2020 AND TIME NE 2021 AND TIME NE 2022 THEN OUTPUT;
RUN;

%ODSoff;
PROC GENMOD DATA=PICCOLI_COMUNI_FEMALE_PRECOVID;
CLASS ITTER107 AGEGROUP / PARAM=GLM;
MODEL DECESSI = POP_MEDIA*AGEGROUP POP_MEDIA*EDUC_RANK POP_MEDIA*EDUC_RANK*TIME1 / DIST=POISSON LINK=IDENTITY SCALE=PEARSON NOINT;
REPEATED SUBJECT=ITTER107*AGEGROUP / TYPE=AR(1) ECOVB;
ODS OUTPUT GEEEmpPEst=educSII_female_GEE_piccoli3;
ODS OUTPUT GEERCov=educSII_female_GEE_piccoli_vcov3;
RUN;
%ODSon;

DATA educSII_female_GEE_piccoli3;
SET educSII_female_GEE_piccoli3;
FORMAT Estimate Stderr LowerCL UpperCL BestD16.; 
RUN;

/* We save coefficients estimates and covariance matrix */

PROC EXPORT DATA=educSII_female_GEE_piccoli3
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\educSII_female_GEE_piccoli3.csv' DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA=educSII_female_GEE_piccoli_vcov3
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\educSII_female_GEE_piccoli_vcov3.csv' DBMS=CSV REPLACE;
RUN;

/* WOMEN - INCOME */

/* 1) Model implementation for SII estimates of income rank with time variable 
as categorical variable for female gender in small municipalities */

%ODSoff;
PROC GENMOD DATA=PICCOLI_COMUNI_FEMALE;
CLASS ITTER107 AGEGROUP TIME / PARAM=GLM;
MODEL DECESSI = POP_MEDIA*AGEGROUP POP_MEDIA*INCOME_RANK*TIME / DIST=POISSON LINK=IDENTITY SCALE=PEARSON NOINT;
REPEATED SUBJECT=ITTER107*AGEGROUP / TYPE=AR(1);
ods output GEEEmpPEst=incomeSII_female_GEE_piccoli;
RUN;
%ODSon;

/* We save coefficients estimates */

DATA incomeSII_female_GEE_piccoli;
SET incomeSII_female_GEE_piccoli;
FORMAT Estimate Stderr LowerCL UpperCL BestD16.; 
RUN;

PROC EXPORT DATA=incomeSII_female_GEE_piccoli
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\incomeSII_female_GEE_piccoli.csv' DBMS=CSV REPLACE;
RUN;

/* 2) Model implementation for SII estimates of income rank with time variable 
as continuous variable for female gender in small municipalities */

%ODSoff;
PROC GENMOD DATA=PICCOLI_COMUNI_FEMALE;
CLASS ITTER107 AGEGROUP / PARAM=GLM;
MODEL DECESSI = POP_MEDIA*AGEGROUP POP_MEDIA*INCOME_RANK POP_MEDIA*INCOME_RANK*TIME1 / DIST=POISSON LINK=IDENTITY SCALE=PEARSON NOINT;
REPEATED SUBJECT=ITTER107*AGEGROUP / TYPE=AR(1) ECOVB;
ODS OUTPUT GEEEmpPEst=incomeSII_female_GEE_piccoli2;
ODS OUTPUT GEERCov=incomeSII_fem_GEE_piccoli_vcov2;
RUN;
%ODSon;

/* We save coefficients estimates and covariance matrix */

DATA incomeSII_female_GEE_piccoli2;
SET incomeSII_female_GEE_piccoli2;
FORMAT Estimate Stderr LowerCL UpperCL BestD16.; 
RUN;

PROC EXPORT DATA=incomeSII_female_GEE_piccoli2
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\incomeSII_female_GEE_piccoli2.csv' DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA=incomeSII_fem_GEE_piccoli_vcov2
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\incomeSII_female_GEE_piccoli_vcov2.csv' DBMS=CSV REPLACE;
RUN;

/* 3) Model implementation for SII estimates of income rank with time variable 
as continuous variable for female gender in small municipalities, excluding the calendar years 2020, 2021 and 2022 */

%ODSoff;
PROC GENMOD DATA=PICCOLI_COMUNI_FEMALE_PRECOVID;
CLASS ITTER107 AGEGROUP / PARAM=GLM;
MODEL DECESSI = POP_MEDIA*AGEGROUP POP_MEDIA*INCOME_RANK POP_MEDIA*INCOME_RANK*TIME1 / DIST=POISSON LINK=IDENTITY SCALE=PEARSON NOINT;
REPEATED SUBJECT=ITTER107*AGEGROUP / TYPE=AR(1) ECOVB;
ODS OUTPUT GEEEmpPEst=incomeSII_female_GEE_piccoli3; 
ODS OUTPUT GEERCov=incomeSII_fem_GEE_piccoli_vcov3;
RUN;
%ODSon;

/* We save coefficients estimates and covariance matrix */

DATA incomeSII_female_GEE_piccoli3;
SET incomeSII_female_GEE_piccoli3;
FORMAT Estimate Stderr LowerCL UpperCL BestD16.; 
RUN;

PROC EXPORT DATA=incomeSII_female_GEE_piccoli3
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\incomeSII_female_GEE_piccoli3.csv' DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA=incomeSII_fem_GEE_piccoli_vcov3
OUTFILE='C:\Users\hp\Documents\UNIMIB\Tesi\Datasets\incomeSII_female_GEE_piccoli_vcov3.csv' DBMS=CSV REPLACE;
RUN;
