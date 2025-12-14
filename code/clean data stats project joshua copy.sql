outline for analysts down the pipeline
NFL QUARTERBACK PREDICTION PROJECT — TEAM SUMMARY & WORKFLOW
1. DATA PREPARATION (JOSH)
Josh is responsible for importing, cleaning, validating, and integrating all raw NFL and college quarterback datasets inside Snowflake. The key output of Josh’s work is a single unified table named QB_ALL that all group members will use for statistical analysis, EDA, hypothesis testing, and machine learning.

Josh’s main tasks:
   * Import raw CSVs into Snowflake

   * Clean and standardize variable names and datatypes

   * Remove unused or incomplete metrics

   * Normalize passing statistics so historical and college datasets align

   * Handle missing values with CASE, COALESCE, and NULL logic

   * Merge historical and prospect datasets using LEFT JOINs and CTEs

   * Create the final unified analytics table: QB_ALL

Final SQL pipeline used by Josh (cleaned and simplified):
"
USE DATABASE SNOWFLAKE_LEARNING_DB;
USE SCHEMA PUBLIC;
CREATE OR REPLACE TABLE QB_ALL AS
WITH
HIST AS (
SELECT
INITCAP(TRIM(NAME)) AS PLAYER,
INITCAP(TRIM(COLLEGE)) AS TEAM_OR_COLLEGE,
INITCAP(TRIM(CONF)) AS CONF,
YEARDRAFTED AS YEAR_DRAFTED,
QBNUMPICKED AS QB_NUM_PICKED,
RDPICKED AS RD_PICKED,
NUMPICKED AS OVERALL_PICK,
HEIGHTIN AS HEIGHT_IN,
WEIGHTLBS AS WEIGHT_LBS,
PCMP AS P_CMP,
PATT AS P_ATT,
CMPPCT AS HIST_CMP_PCT,
PYDS AS P_YDS,
PYPA AS P_YPA,
PADJYPA AS P_ADJ_YPA,
PTD AS P_TD,
INT AS P_INTS,
RATE AS HIST_RATE,
RATT AS R_ATT,
RYDS AS R_YDS,
RAVG AS R_AVG,
RTDS AS R_TDS,
NFLSTARTS AS NFL_STARTS,
NFLWINS AS NFL_WINS,
NFLLOSSES AS NFL_LOSSES,
NFLTIES AS NFL_TIES,
NFLWINPR AS NFL_WIN_PR,
NFLQBR AS NFL_QBR,
NFLYDS AS NFL_YDS,
NFLTDS AS NFL_TDS,
NFLINT AS NFL_INT
FROM INDEX
),
PROSPECTS AS (
SELECT
INITCAP(TRIM(PLAYER)) AS PLAYER,
INITCAP(TRIM(TEAM)) AS TEAM_OR_COLLEGE,
INITCAP(TRIM(CONF)) AS CONF,
CMP AS CMP,
ATT AS ATT,
CMPPERCENT AS CMP_PCT,
YDS AS YDS,
TD AS TD,
INT AS INTS,
YIA AS Y_PER_ATT,
AYIA AS ADJ_Y_PER_ATT,
RATE AS RATE
FROM QB
),
HIST_WITH_MATCH AS (
SELECT
'HISTORICAL' AS RECORD_TYPE,
h.PLAYER,
h.TEAM_OR_COLLEGE,
h.CONF,
h.YEAR_DRAFTED,
h.QB_NUM_PICKED,
h.RD_PICKED,
h.OVERALL_PICK,
h.HEIGHT_IN,
h.WEIGHT_LBS,
COALESCE(p.CMP, h.P_CMP) AS CMP,
COALESCE(p.ATT, h.P_ATT) AS ATT,
COALESCE(p.CMP_PCT, h.HIST_CMP_PCT) AS CMP_PCT,
COALESCE(p.YDS, h.P_YDS) AS YDS,
COALESCE(p.TD, h.P_TD) AS TD,
COALESCE(p.INTS, h.P_INTS) AS INTS,
COALESCE(p.Y_PER_ATT, h.P_YPA) AS Y_PER_ATT,
COALESCE(p.ADJ_Y_PER_ATT, h.P_ADJ_YPA) AS ADJ_Y_PER_ATT,
COALESCE(p.RATE, h.HIST_RATE) AS RATE,
h.R_ATT,
h.R_YDS,
h.R_AVG,
h.R_TDS,
h.NFL_STARTS,
h.NFL_WINS,
h.NFL_LOSSES,
h.NFL_TIES,
h.NFL_WIN_PR,
h.NFL_QBR,
h.NFL_YDS,
h.NFL_TDS,
h.NFL_INT,
CASE WHEN h.QB_NUM_PICKED IS NULL THEN 0 ELSE 1 END AS DRAFTED_FLAG
FROM HIST h
LEFT JOIN PROSPECTS p
ON h.PLAYER = p.PLAYER AND h.CONF = p.CONF
),
PROSPECTS_ONLY AS (
SELECT
'PROSPECT' AS RECORD_TYPE,
p.PLAYER,
p.TEAM_OR_COLLEGE,
p.CONF,
NULL::NUMBER AS YEAR_DRAFTED,
NULL::NUMBER AS QB_NUM_PICKED,
NULL::NUMBER AS RD_PICKED,
NULL::NUMBER AS OVERALL_PICK,
NULL::NUMBER AS HEIGHT_IN,
NULL::NUMBER AS WEIGHT_LBS,
p.CMP AS CMP,
p.ATT AS ATT,
p.CMP_PCT AS CMP_PCT,
p.YDS AS YDS,
p.TD AS TD,
p.INTS AS INTS,
p.Y_PER_ATT AS Y_PER_ATT,
p.ADJ_Y_PER_ATT AS ADJ_Y_PER_ATT,
p.RATE AS RATE,
NULL::NUMBER AS R_ATT,
NULL::NUMBER AS R_YDS,
NULL::NUMBER AS R_AVG,
NULL::NUMBER AS R_TDS,
NULL::NUMBER AS NFL_STARTS,
NULL::NUMBER AS NFL_WINS,
NULL::NUMBER AS NFL_LOSSES,
NULL::NUMBER AS NFL_TIES,
NULL::NUMBER AS NFL_WIN_PR,
NULL::NUMBER AS NFL_QBR,
NULL::NUMBER AS NFL_YDS,
NULL::NUMBER AS NFL_TDS,
NULL::NUMBER AS NFL_INT,
0 AS DRAFTED_FLAG
FROM PROSPECTS p
LEFT JOIN HIST h
ON p.PLAYER = h.PLAYER AND p.CONF = h.CONF
WHERE h.PLAYER IS NULL
)
SELECT * FROM HIST_WITH_MATCH
UNION ALL
SELECT * FROM PROSPECTS_ONLY;
"
Everyone will use this QB_ALL table for their analysis.
________________


      2. EXPLORATORY DATA ANALYSIS (LANDON)

________________


Landon uses QB_ALL to:
         * Visualize distributions of passing statistics

         * Identify important variables (CMP_PCT, RATE, Y_PER_ATT, ADJ_Y_PER_ATT)

         * Compare drafted vs undrafted QBs

         * Understand the structure of the 2025 prospect class

         * Produce correlation heatmaps and boxplots

Goal: Help guide Robert’s machine learning modeling by highlighting which variables show promising separation between groups.
________________


            3. SUPERVISED MACHINE LEARNING (ROBERT)

________________


Robert uses only historical rows:
"SELECT * FROM QB_ALL WHERE RECORD_TYPE = 'HISTORICAL';"
Tasks:
               * Build at least two supervised models (KNN required + Logistic Regression or Random Forest)

               * Build one unsupervised model (K-Means or Hierarchical)

               * Train using predictors: CMP_PCT, Y_PER_ATT, ADJ_Y_PER_ATT, RATE, TD, INTS, HEIGHT_IN, WEIGHT_LBS, Rushing stats

               * Target variable: DRAFTED_FLAG

               * Predict draft probability for each prospect in QB_ALL

Goal: Assign each 2025 QB a probability of being drafted.
________________


                  4. TWO-POPULATION TESTING (IVAN)

________________


Ivan compares two historical groups:
Group 1: DRAFTED_FLAG = 1
Group 2: DRAFTED_FLAG = 0
Hypothesis examples:
                     * Do drafted QBs have significantly higher YDS?

                     * Do they have higher CMP_PCT?

                     * Is Y_PER_ATT meaningfully different?

He performs:
                        * Welch’s t-test

                        * Two-sample independent t-test

Queries he uses:
"SELECT YDS, CMP_PCT, Y_PER_ATT, ADJ_Y_PER_ATT FROM QB_ALL WHERE RECORD_TYPE='HISTORICAL';"
Goal: Provide statistical evidence supporting which variables separate the two groups.
________________


                           5. ONE-WAY ANOVA (TREVOR)

________________


Trevor uses historical QBs to compare differences across groups such as:
                              * Draft round (RD_PICKED)

                              * Conference (CONF)

                              * Performance tier (based on RATE)

Examples:
                                 * Do conferences differ in average RATE?

                                 * Is mean Y_PER_ATT different across draft rounds?

Uses ANOVA and Tukey post-hoc tests.
Goal: Identify meaningful group-level effects across player categories.
________________


                                    6. FINAL PRESENTATION & PYTHON VISUALIZATION

________________


Anyone can use Python to produce final graphics:
                                       * Draft probability bar charts

                                       * Correlation heatmaps

                                       * Distributions comparing drafted vs undrafted

                                       * Top prospects ranking report

Key dataset loaded via:
"SELECT * FROM QB_ALL;"




table definitions
RECORD_TYPE        VARCHAR(10) 
PLAYER        VARCHAR(16777216) 
TEAM_OR_COLLEGE        VARCHAR(16777216)
CONF        VARCHAR(16777216) 
YEAR_DRAFTED        NUMBER(38,0)
QB_NUM_PICKED        NUMBER(38,0) 
RD_PICKED        NUMBER(38,0)
OVERALL_PICK        NUMBER(38,0) 
HEIGHT_IN        NUMBER(38,0)
WEIGHT_LBS        NUMBER(38,0) 
CMP        NUMBER(38,1) 
ATT        NUMBER(38,1)
CMP_PCT        NUMBER(38,1) 
YDS        NUMBER(38,1)
TD        NUMBER(38,1)
INTS        NUMBER(38,1)
Y_PER_ATT        NUMBER(38,1)
ADJ_Y_PER_ATT        NUMBER(38,2)
RATE        NUMBER(38,1)
R_ATT        NUMBER(38,0)
R_YDS        NUMBER(38,0)
R_AVG        NUMBER(38,1) 
R_TDS        NUMBER(38,0) 
NFL_STARTS        NUMBER(38,0) 
NFL_WINS        NUMBER(38,0) 
NFL_LOSSES        NUMBER(38,0) 
NFL_TIES        NUMBER(38,0) 
NFL_WIN_PR        NUMBER(38,2) 
NFL_QBR        NUMBER(38,1) 
NFL_YDS        NUMBER(38,0) 
NFL_TDS        NUMBER(38,0) 
NFL_INT        NUMBER(38,0) 
DRAFTED_FLAG        NUMBER(1,0)
code + file
–(the file is in discord)


USE DATABASE SNOWFLAKE_LEARNING_DB;
USE SCHEMA PUBLIC;


CREATE OR REPLACE TABLE QB_ALL AS
WITH
HIST AS (
    SELECT
        INITCAP(TRIM(NAME))        AS PLAYER,
        INITCAP(TRIM(COLLEGE))     AS TEAM_OR_COLLEGE,
        INITCAP(TRIM(CONF))        AS CONF,


        YEARDRAFTED                AS YEAR_DRAFTED,
        QBNUMPICKED                AS QB_NUM_PICKED,
        RDPICKED                   AS RD_PICKED,
        NUMPICKED                  AS OVERALL_PICK,


        HEIGHTIN                   AS HEIGHT_IN,
        WEIGHTLBS                  AS WEIGHT_LBS,


        -- College passing
        PCMP                       AS P_CMP,
        PATT                       AS P_ATT,
        CMPPCT                     AS HIST_CMP_PCT,
        PYDS                       AS P_YDS,
        PYPA                       AS P_YPA,
        PADJYPA                    AS P_ADJ_YPA,
        PTD                        AS P_TD,
        INT                        AS P_INTS,
        RATE                       AS HIST_RATE,


        -- College rushing
        RATT                       AS R_ATT,
        RYDS                       AS R_YDS,
        RAVG                       AS R_AVG,
        RTDS                       AS R_TDS,


        -- NFL outcome
        NFLSTARTS                  AS NFL_STARTS,
        NFLWINS                    AS NFL_WINS,
        NFLLOSSES                  AS NFL_LOSSES,
        NFLTIES                    AS NFL_TIES,
        NFLWINPR                   AS NFL_WIN_PR,
        NFLQBR                     AS NFL_QBR,
        NFLYDS                     AS NFL_YDS,
        NFLTDS                     AS NFL_TDS,
        NFLINT                     AS NFL_INT
    FROM INDEX
),


-- 2) Clean / curate current college QB data from QB
PROSPECTS AS (
    SELECT
        INITCAP(TRIM(PLAYER))      AS PLAYER,
        INITCAP(TRIM(TEAM))        AS TEAM_OR_COLLEGE,
        INITCAP(TRIM(CONF))        AS CONF,


        CMP                        AS CMP,
        ATT                        AS ATT,
        CMPPERCENT                 AS CMP_PCT,
        YDS                        AS YDS,
        TD                         AS TD,
        INT                        AS INTS,
        YIA                        AS Y_PER_ATT,
        AYIA                       AS ADJ_Y_PER_ATT,
        RATE                       AS RATE
    FROM QB
),


-- 3) Historical rows (with any matching prospect info if it exists)
HIST_WITH_MATCH AS (
    SELECT
        'HISTORICAL'                       AS RECORD_TYPE,
        h.PLAYER,
        h.TEAM_OR_COLLEGE,
        h.CONF,


        -- Draft info
        h.YEAR_DRAFTED,
        h.QB_NUM_PICKED,
        h.RD_PICKED,
        h.OVERALL_PICK,


        -- Physical
        h.HEIGHT_IN,
        h.WEIGHT_LBS,


        -- College passing (prefer prospect stats if matched, otherwise historical)
        COALESCE(p.CMP,  h.P_CMP)              AS CMP,
        COALESCE(p.ATT,  h.P_ATT)              AS ATT,
        COALESCE(p.CMP_PCT, h.HIST_CMP_PCT)    AS CMP_PCT,
        COALESCE(p.YDS, h.P_YDS)               AS YDS,
        COALESCE(p.TD,  h.P_TD)                AS TD,
        COALESCE(p.INTS, h.P_INTS)             AS INTS,
        COALESCE(p.Y_PER_ATT,    h.P_YPA)      AS Y_PER_ATT,
        COALESCE(p.ADJ_Y_PER_ATT, h.P_ADJ_YPA) AS ADJ_Y_PER_ATT,
        COALESCE(p.RATE, h.HIST_RATE)          AS RATE,


        -- College rushing from historical
        h.R_ATT,
        h.R_YDS,
        h.R_AVG,
        h.R_TDS,


        -- NFL outcomes
        h.NFL_STARTS,
        h.NFL_WINS,
        h.NFL_LOSSES,
        h.NFL_TIES,
        h.NFL_WIN_PR,
        h.NFL_QBR,
        h.NFL_YDS,
        h.NFL_TDS,
        h.NFL_INT,


        -- Drafted flag (pure data field for historical)
        CASE 
            WHEN h.QB_NUM_PICKED IS NULL THEN 0 
            ELSE 1 
        END                                 AS DRAFTED_FLAG
    FROM HIST h
    LEFT JOIN PROSPECTS p
      ON h.PLAYER = p.PLAYER
     AND h.CONF   = p.CONF
),


-- 4) Prospect rows that didn't match any historical player
PROSPECTS_ONLY AS (
    SELECT
        'PROSPECT'                         AS RECORD_TYPE,
        p.PLAYER,
        p.TEAM_OR_COLLEGE,
        p.CONF,


        -- No draft info yet
        NULL::NUMBER                       AS YEAR_DRAFTED,
        NULL::NUMBER                       AS QB_NUM_PICKED,
        NULL::NUMBER                       AS RD_PICKED,
        NULL::NUMBER                       AS OVERALL_PICK,


        -- No physical attributes in QB table
        NULL::NUMBER                       AS HEIGHT_IN,
        NULL::NUMBER                       AS WEIGHT_LBS,


        -- College passing directly from prospects
        p.CMP                              AS CMP,
        p.ATT                              AS ATT,
        p.CMP_PCT                          AS CMP_PCT,
        p.YDS                              AS YDS,
        p.TD                               AS TD,
        p.INTS                             AS INTS,
        p.Y_PER_ATT                        AS Y_PER_ATT,
        p.ADJ_Y_PER_ATT                    AS ADJ_Y_PER_ATT,
        p.RATE                             AS RATE,


        -- No rushing or NFL stats for prospects
        NULL::NUMBER                       AS R_ATT,
        NULL::NUMBER                       AS R_YDS,
        NULL::NUMBER                       AS R_AVG,
        NULL::NUMBER                       AS R_TDS,
        NULL::NUMBER                       AS NFL_STARTS,
        NULL::NUMBER                       AS NFL_WINS,
        NULL::NUMBER                       AS NFL_LOSSES,
        NULL::NUMBER                       AS NFL_TIES,
        NULL::NUMBER                       AS NFL_WIN_PR,
        NULL::NUMBER                       AS NFL_QBR,
        NULL::NUMBER                       AS NFL_YDS,
        NULL::NUMBER                       AS NFL_TDS,
        NULL::NUMBER                       AS NFL_INT,


        0                                   AS DRAFTED_FLAG   -- prospects explicitly 0
    FROM PROSPECTS p
    LEFT JOIN HIST h
      ON p.PLAYER = h.PLAYER
     AND p.CONF   = h.CONF
    WHERE h.PLAYER IS NULL
)


-- 5) Final unified result, with only the kept columns
SELECT
    RECORD_TYPE,
    PLAYER,
    TEAM_OR_COLLEGE,
    CONF,
    YEAR_DRAFTED,
    QB_NUM_PICKED,
    RD_PICKED,
    OVERALL_PICK,
    HEIGHT_IN,
    WEIGHT_LBS,
    CMP,
    ATT,
    CMP_PCT,
    YDS,
    TD,
    INTS,
    Y_PER_ATT,
    ADJ_Y_PER_ATT,
    RATE,
    R_ATT,
    R_YDS,
    R_AVG,
    R_TDS,
    NFL_STARTS,
    NFL_WINS,
    NFL_LOSSES,
    NFL_TIES,
    NFL_WIN_PR,
    NFL_QBR,
    NFL_YDS,
    NFL_TDS,
    NFL_INT,
    DRAFTED_FLAG
FROM HIST_WITH_MATCH


UNION ALL


SELECT
    RECORD_TYPE,
    PLAYER,
    TEAM_OR_COLLEGE,
    CONF,
    YEAR_DRAFTED,
    QB_NUM_PICKED,
    RD_PICKED,
    OVERALL_PICK,
    HEIGHT_IN,
    WEIGHT_LBS,
    CMP,
    ATT,
    CMP_PCT,
    YDS,
    TD,
    INTS,
    Y_PER_ATT,
    ADJ_Y_PER_ATT,
    RATE,
    R_ATT,
    R_YDS,
    R_AVG,
    R_TDS,
    NFL_STARTS,
    NFL_WINS,
    NFL_LOSSES,
    NFL_TIES,
    NFL_WIN_PR,
    NFL_QBR,
    NFL_YDS,
    NFL_TDS,
    NFL_INT,
    DRAFTED_FLAG
FROM PROSPECTS_ONLY;




SELECT *
FROM QB_ALL
;
desc table qb_all;