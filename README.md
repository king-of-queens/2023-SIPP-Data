The Effect of Education on Income
================
Samuel Queen
19 June, 2025

## Introduction

This project serves as my reintroduction to econometric techniques,
using statistical methods, and is my first foray into the R language. I
have been teaching myself R and started using it more at work and felt
like now was the time to take on my first research project. We start
with a simple question, does having more education lead to higher
earnings? There are what seem to be entire libraries dedicated to this
research topic, so I will not pretend to say I have uncovered some
groundbreaking revelations or anything like that. In fact we already
know the answer, and it is a resounding yes. What I am attempting to do
is see if this relationship is present within Census SIPP (survey of
income and program participation) survey data and if I can accurately
model/capture the expected increase in income. This will be a cross
sectional analysis using a multiple OLS general survey regression model.

To learn more about SIPP data click here:  
[SIPP Overview](https://www.census.gov/programs-surveys/sipp.html)  
[About SIPP](https://www.census.gov/programs-surveys/sipp/about.html)  
[SIPP
Methodology](https://www.census.gov/programs-surveys/sipp/methodology.html)

To learn more about the assumptions for OLS regressions, click here:  
[Linear Regression
Overview](https://en.wikipedia.org/wiki/Linear_regression)

## Exploratory Data Analysis

Before we dive into our main insights and investigation through linear
regression, we must first explore the covariation between our main
explanatory variables (education levels, age, race, and gender) to
visually confirm that there are observable trends between them and
monthly income. This will also help us to confirm the trends that are
common knowledge as well. The basic insights gleaned here should provide
evidence that I am correct in using these variables to capture the
effects of education on income. Lastly, I am going to show that the
variables described in the Mincer Equation for human capital earnings
are a good basis for this statistical model.

Let’s first start by visualizing the relationship between educational
attainment and reported monthly income. Notice there are two charts, the
first visualizes the relationship between high school diploma attainment
and monthly income, while the second plot shows a more detailed
breakdown of education by secondary and post secondary educational
attainment.

![](https://github.com/king-of-queens/2023-SIPP-Data/blob/7b673716373e3c9a69aef375461e1a074a695a59/HS%20diploma%20graph-1.png)

As we expect, there is a noticeable trend that shows that earning a high
school diploma typically results in a higher reported monthly income.
However, there are a noticeable amount of outlier observations that do
not fit within the minimum or maximum (the 0th percentile or the 100th
percentile) using the standard 1.5 IQR distance from the upper quartile
(Q3) and the lower quartile (Q1). These outliers are mainly located in
the “Above HS Diploma” category. This is reasonable to see as that
category is a combination of more detailed educational outcomes. For
example, a respondent with an Associate’s degree and another respondent
with a Master’s degree are both labeled as “Above HS Diploma” in this
plot. Higher degrees of variation make sense using these descriptors. I
expect to see a lower amount of outliers if I expand the educational
attainment variables to a more detailed level. Lets see what that plot
looks like.

![](https://github.com/king-of-queens/2023-SIPP-Data/blob/7b673716373e3c9a69aef375461e1a074a695a59/detailed%20educational%20attainment%20graph-1.png)

As expected, we see a similar trend, higher education showing a higher
median monthly income amount. We also get a better sense of where our
outliers live, specifically which educational attainment category. By my
eye, the categories for Bachelor’s and Master’s degree have the highest
frequency of outliers compared to the other categories. Regardless, the
generally positive trend we see for educational attainment helps us to
confirm that we are investigating in the right area and are honing in on
a solid foundation for our linear regression.

Now that we have visualized the basic relationship between our main
variable of interest (educational attainment) and our dependent variable
(income) we must also consider other covariates that are necessary for
accurate modeling and in-depth analysis. For this we will base our
analysis on the widely used Mincer Earnings Function. The Mincer
Earnings Function is a single equation model that describes wage income
as a function of schooling and experience. The parameters ρ, and β1, β2
can be interpreted as the returns to schooling and experience,
respectively.

![](https://github.com/king-of-queens/2023-SIPP-Data/blob/7b673716373e3c9a69aef375461e1a074a695a59/mincer%20eq.PNG)

One of the key attributes of this specific model is the quadratic
function that captures “years of potential experience”. For this
analysis, I determined that age of the respondent (specifically at the
time of the interview) can act as a substitute for work experience. I
would have liked to include some type of “time spent at job” or
“seniority level” variable to directly reflect this but I could not find
a question that specific. However, visually speaking the age variable
will suffice.

    ## `geom_smooth()` using method = 'gam' and formula = 'y ~ s(x, bs = "cs")'

![](https://github.com/king-of-queens/2023-SIPP-Data/blob/7b673716373e3c9a69aef375461e1a074a695a59/age%20covariation%20graph-1.png)

Age follows the diminishing returns described and captured by experience
and experience^2 quite well (at least good enough for this analyst!). On
first glance, the general shape of the age variable shows that monthly
income rises but seems to peak and may even fall as one approaches the
age of typical retirement (64). Conveniently, I have chosen to analyze
only adults within typical working age (18-64). Using the line of best
fit, wages seem to peak around 35 or 40 in this dataset and then
stabilize or even may drop down around the age of 60. Based on previous
literature (that has gone more in depth with theoretical proofs) the
trend of slowly diminishing returns as a worker gains more experience in
their role is modeled quite nicely by our age variable. This gives me
confidence to use it as a main explanatory variable for our regression.

![](https://github.com/king-of-queens/2023-SIPP-Data/blob/7b673716373e3c9a69aef375461e1a074a695a59/race%20covariation%20graph-1.png)

Grouping the survey responses into racial cohorts provides interesting
insights as well. Visually we can see that the Asian group has the
largest median monthly income with the White cohort in second. The Black
and Other cohorts show similar characteristics and are relatively the
same, tied for third in this basic comparison. There is another variable
within the SIPP dataset that I could have pulled that expanded upon the
“Other” category. However, I deemed this variable quality enough for the
scope of this project. If further analysis were to be conducted I would
go back and restructure the data to include the more detailed racial
categories. For now this will suffice. Overall, I expect that the race
demographic variable will have a significant impact on the model as a
control.

![](https://github.com/king-of-queens/2023-SIPP-Data/blob/7b673716373e3c9a69aef375461e1a074a695a59/gender%20covariation%20graph-1.png)

As expected, the median monthly income, when comparing across gender
groups displays the commonly known economic characteristic that males in
the workforce earn more income than females. There is an enormous amount
of literature and research that attempts to explain this phenomenon and
propose ideas to counteract it. I won’t go into too much more detail
regarding this covariate. For our purposes, we are merely looking to see
if the dataset we have created accurately reflects current reality (or
the one that existed at the time of the interviews). What we see here in
the data we can confirm with other outside sources of information. I
expect this variable to have a significant impact on the model as well.
It may even have an impact on the explanatory variable of interest
(educational attainment) and further treatment would be needed to
control for the potential co-linearity or other endogenous effects that
gender might have on educational outcomes.

## Survey Design and Regression Analysis

SIPP survey data organization is structured into panels, waves, and
reference periods. A SIPP panel is a group of households selected to be
interviewed periodically over multiple years. These panels may run
concurrently with others or alone. Waves created within each panel and
are defined as a full cycle of administering the survey questions. From
2014 and on, each SIPP panel consist of 4 waves. Most SIPP questions
asked during the interview referred to the preceding calendar year, this
is the “reference period”. So for the 2023 SIPP survey, the questions
asked referred to January to December 2022.

The SIPP sampling design is complex and goes above simple random
sampling to determine which households are selected for an interview
(see stratified sampling for further details). Because of this complex
design, there are important guidelines needed when using SIPP data to
properly account for standard error estimation. Because of the nature of
the survey design, unless properly accounted for, the standard errors
generated from typical modeling or other statistical analysis will
underestimate the true standard errors of estimates from SIPP data.

``` r
sipp_design <- svrepdesign(
  data = Final_Data_SIPP_2023,
  type = "Fay",
  repweights = "REPWGT[0-9]+",
  weights = ~WPFINWGT,
  combined.weights = TRUE,
  rho = 0.5,
  mse = TRUE
)
```

To properly account for the standard errors generated from non random
sampling, I followed guidelines from the Census and attached the proper
2023 replicate weights to the core data. These were combined via
specific identifier variables provided by SIPP data documentation. I
chose to implement Fay’s Method of Balanced Repeated Replication in my
analysis as it follows previous government and academic research using
complex panel data, it provides consistency in variance estimation. See
(<https://www.bls.gov/osmr/research-papers/2008/pdf/st080070.pdf>) for
further insight into the effectiveness of Fay’s method for standard
errors. The main concern with this choice is the potential for variance
underestimation for small sample sizes. Other methodologies (Taylor
Series, Balanced Repeated Replication, Jackknife, etc) all contain their
own drawbacks as well. Fay’s Method is seen as the easiest to compute
and implement.

### First OLS Regression (mimicking the Mincer Equation)

``` r
Weighted_OLS_model <- svyglm(log_monthly_income ~ `education_type_Above HS Diploma` + 
                               TAGE + 
                               I(TAGE^2),
                    design = sipp_design)
```

Our first model attempts to replicate the Mincer Equation as is, this
will help test the foundation of our analysis and help us know if we are
going in the right direction. Using age (variable name TAGE) as a
substitute for work experience, we see above our monthly income variable
modeled as a function of educational attainment (in this case a dummy
response of yes or no for “above high school diploma education level),
age, and age^2.

### Second OLS Regression (adding in other explanatory variables based on the graphs from earlier)

``` r
Weighted_OLS_model2 <- svyglm(log_monthly_income ~ `education_type_Above HS Diploma` + 
                                TAGE + I(TAGE^2) + 
                                sex + race + hisp_origin + living_quarters + 
                                license_or_cert +  martial_status + empstatus,
                     design = sipp_design)
```

Our second model introduces a set of demographic and other control
variables contained within the SIPP dataset, including race, gender,
Hispanic origin, marital status, and employment status to name a few.
Theoretically, the inclusion of these variables will help to reduce the
error term and create homogeneity in the models residuals, among other
positive impacts. Generally speaking, I chose a multi-variable linear
regression model for a couple of reasons. Firstly, this is the beginning
of my return into “academic” type research, specifically with the
implementation of econometrics. It has been since early 2021 since my
last academic research project and I needed something manageable enough
to not get lost in the sauce of theory while also not venturing into
causal claims just yet. The groundwork for that type of analysis is
hopefully being laid here. One day I will be confident enough and have a
solid background to dive into questions like that, but as of right now
OLS is where I live. And this is no knock to OLS estimations, there is a
reason it is still being taught today.

### Comparison of the Two Models

    ## 
    ## Multiple OLS Regression Results Comparison Table
    ## ===================================================================================
    ##                                                   log_monthly_income               
    ##                                     Mincer Equation | Mincer Equation with Controls
    ##                                            (1)                     (2)             
    ## -----------------------------------------------------------------------------------
    ## Education Above HS Diploma              0.538***                0.392***           
    ##                                      (0.501, 0.574)          (0.356, 0.427)        
    ##                                                                                    
    ## Age                                     0.125***                0.078***           
    ##                                      (0.116, 0.135)          (0.069, 0.087)        
    ##                                                                                    
    ## Age²                                    -0.001***               -0.001***          
    ##                                     (-0.001, -0.001)        (-0.001, -0.001)       
    ##                                                                                    
    ## Male (ref:Female)                                               0.314***           
    ##                                                              (0.280, 0.347)        
    ##                                                                                    
    ## Black (ref:Asian)                                               -0.258***          
    ##                                                             (-0.341, -0.176)       
    ##                                                                                    
    ## Other Race (ref:Asian)                                          -0.232***          
    ##                                                             (-0.341, -0.124)       
    ##                                                                                    
    ## White (ref:Asian)                                               -0.127***          
    ##                                                             (-0.201, -0.053)       
    ##                                                                                    
    ## Hispanic Origin                                                 -0.152***          
    ##                                                             (-0.193, -0.111)       
    ##                                                                                    
    ## Living Quarters: House/Apt/Flat                                  0.404*            
    ##                                                              (-0.030, 0.837)       
    ##                                                                                    
    ## Living Quarters: Mobile Home/Other)                               0.173            
    ##                                                              (-0.268, 0.613)       
    ##                                                                                    
    ## Obtained Professional License/Cert.                             0.117***           
    ##                                                              (0.081, 0.154)        
    ##                                                                                    
    ## Married (ref:Divorced)                                          0.107***           
    ##                                                              (0.055, 0.160)        
    ##                                                                                    
    ## Never Married (ref:Divorced)                                    -0.098***          
    ##                                                             (-0.158, -0.039)       
    ##                                                                                    
    ## Separated (ref:Divorced)                                         -0.021            
    ##                                                              (-0.154, 0.113)       
    ##                                                                                    
    ## Widowed (ref:Divorced)                                            0.047            
    ##                                                              (-0.060, 0.154)       
    ##                                                                                    
    ## Unemployed (ref:Employed)                                       -1.314***          
    ##                                                             (-1.368, -1.260)       
    ##                                                                                    
    ## Intercept                               5.157***                5.820***           
    ##                                      (4.966, 5.348)          (5.333, 6.308)        
    ##                                                                                    
    ## Observations                             15,881                  15,501            
    ## Log Likelihood                         -23,609.290             -20,747.390         
    ## Akaike Inf. Crit.                      47,226.580              41,528.780          
    ## -----------------------------------------------------------------------------------
    ## Notes:                              ***Significant at the 1 percent level.         
    ##                                     **Significant at the 5 percent level.          
    ##                                     *Significant at the 10 percent level.

Our first model (Mincer Eq) shows that the variables included (education
beyond HS, age, and age²) and the intercept itself are statistically
significant at the generally accepted level of 95% and even at the 99%
confidence level. The confidence intervals (the set of values below each
coefficient) for model 1 show that our estimated range of the beta
parameter does not include 0, meaning that age and education have a
significant and non zero impact on monthly education within this
dataset.

Moving on to the Mincer + Controls model we find similar results for the
same variables that are present in model 1. Education above HS Diploma
and age are still statistically significant and the trends of each
variable seem to be accurately captured within the model. The estimated
confidence intervals tell a similar story, zero is outside the bounds of
both education and age meaning we can reject the null hypothesis that
the true beta parameter is 0. Moving to the other control variables, the
racial demographic variables and the sex indicator variable were
statistically significant at both the 95% and 99% level. Travelling down
the list we find that Hispanic origin, obtaining a professional
license/certification, select marriage indicators (married and never
married), and the employment status variable are all statistically
significant as well at the levels mentioned previously.

### Comparision of Both Model Coefficients

| Mincer Equation | Mincer Equation with Controls |
|:---------------:|:-----------------------------:|
|      1.712      |             1.48              |

Coefficients for Educational Attainment (Above HS Diploma)

The table above neatly displays the explanatory variable of interest for
this analysis. Before interpreting these values, it is important to note
that since the model is log-linear in nature, exponentiating the
coefficient is required to properly interpret the results of the model.
For every 1 unit increase in education type (i.e going from a HS Diploma
to some type of higher educational attainment), we see and increase in
monthly income by 71.2% in the first Mincer model, while the Mincer +
Controls Model found an increase of 48.0%. Notice how that works. The
coefficients in the regression output are 0.538 (model 1) and 0.392
(model 2). After converting the values using some R code, we come up
with our real world interpretation. Imagine that we are taking the
hypothetical value for monthly income at the high school diploma level
and then multiplying it by 1.71, aka, taking the current value and
adding 71.1%. The difference between the two outputs is expected, as we
add in more control variables to the model the size of each coefficient
should reduce, as more of the excess noise is being captured by the
model predictors and not the error term.

| Male (ref:Female) | Black (ref:Asian) | Other (ref:Asian) | White (ref:Asian) | Obtained Professional License/Cert. |
|:--:|:--:|:--:|:--:|:--:|
| 1.369 | 0.772 | 0.793 | 0.881 | 1.124 |

Coefficients for Other Explanatory Variables of Interest

The table above shows other independent variables I found interesting
and predicted would have a significant impact back in the EDA section.
Before continuing, I should make note that unless a dummy/indicator is
designated within the linear regression (for a categorical variable,
non-ordinal), R will use the first category listed (A-Z or numerically
if coded as a numbers) as the reference category and base the
coefficients on the reference category. This should help contextualize
the results of my analysis.

Starting with the sex variable, our model reports that males earn a wage
that is 36.9% higher than the reference category of females in the
dataset. This variable had a significant impact on the results of the
model as well. More analysis may need to be done in order to fully flesh
out the interconnectedness of gender, education, and income. The race
variable had a significant effect on our models results as well and
seems to accurately reflect real world conditions to boot. The Black
cohort made 77.2% of the monthly income that the reference group did
(Asian in this case), the Other category made 79.3% of the income
compared to the reference group, and the White cohort made 88.1%
compared to Asians.

The last variable of interest to me was the professional license or
certification indicator variable. This is actually the variable that
first sparked my interest in the project. I thought it could be useful
for educational and other organizations that promote workforce
development to know whether or not their work-based education programs
made a noticeable impact on the participants income levels. The Mincer
Equation in addition with other covariates (with organization or
enterprise specific data) could be very effective for internal
evaluation or external reporting. From my model, I found that those with
a professional license or certification make 12.4% more monthly income
than those without these additional education gains.

## Robustness Check and Model Specification

This section of my report will consist of a brief discussion on model
specification and whether or not we appropriately measured the effects
of education levels on income. The traditional method of evaluating
model selection is through a robustness check of residuals and
visualization of said residuals generated from linear regression. I will
not deviate from a tried and true methodology. The results are as
follows.

![](https://github.com/king-of-queens/2023-SIPP-Data/blob/7b673716373e3c9a69aef375461e1a074a695a59/discussion%20section-1.png)

After some initial manipulation including filtering and logarithmic
operations, the income variable is normally distributed, at least
generally. There is no real world data that will follow an exactly
normal distribution, so what we are seeing here will suffice and works
for our general assumptions for linear modeling.

### Visualizing the Residuals for Both Models

#### Residuals vs Fitted Values Plots

![](https://github.com/king-of-queens/2023-SIPP-Data/blob/7b673716373e3c9a69aef375461e1a074a695a59/residuals%20vs%20fitted-1.png)

These two residuals vs. fitted plots help visualize any potential
non-linear patterns within both models’ residuals. From my eye, there is
no distinct pattern around the center line of 0, and the red line that
follows the residual data shows only slight deviation above and below
the defined pearson residual line. There may be some concerns with the
distribution or density of the residuals however, to me there appear to
be a large concentration of points between 7.5 and 8 and around 8.5 (in
the first Mincer Model). While not as apparent, there appears to be a
higher density of residuals as we travel right along the x axis for the
Mincer + Controls plot as well. However overall, I would say our
residuals vs fitted values plot passed linearity tests, reducing our
concerns of a biased estimator.

#### Normal Q-Q Residuals Plots

![](https://github.com/king-of-queens/2023-SIPP-Data/blob/7b673716373e3c9a69aef375461e1a074a695a59/QQ%20residuals-1.png)

While our residuals versus fitted values plot looks good, there are some
serious concerns with the trends seen in both QQ plots for our chosen
models. The first two theoretical quantiles look fine, but as soon as we
expand into the 3rd and 4th quantiles we see severe deviation and a
non-normal distribution of residuals. Typically this means our sample
data is skewed in some way. My first thoughts on the matter are that
there are more responses in the survey for “above high school diploma”
than the other categories, resulting in the right-hand skew of our data.
See the table below.

|         education_type         |   n   | percent |
|:------------------------------:|:-----:|:-------:|
|        Above HS Diploma        | 10523 |  66.3%  |
| High School Diploma/Equivalent | 4135  |  26.0%  |
|      Less than HS Diploma      | 1223  |  7.7%   |

Education Levels Table

We can now see what might be the source of the right skew in the data.
The Above HS Diploma category accounts for almost exactly two-thirds of
total responses within the education type variable (our main covariate!)
and needs to be addressed. My thoughts from the beginning of this report
may ring true after all. I should take into account this skewedness and
may need to re-specify that the model be ran with another variable that
captures educational attainment to a more detailed level.

#### Scale-Location Plots

![](https://github.com/king-of-queens/2023-SIPP-Data/blob/7b673716373e3c9a69aef375461e1a074a695a59/scale-location-1.png)

Our last robustness check will a test for homoscedasticity (constant
variance of residuals). OLS regressions assume that the residuals
generated by the model have equal variance and display no systemic
patterns or changes (i.e their mean is 0). If there is
heteroscedasticity our results would be very difficult to trust as there
would be increased variance in our coefficients not properly captured by
the model. Which could potentially lead to type 1 or type 2 errors in
our hypothesis testing. In this instance, the residual variance appears
to be generally constant. For both plots the red line is roughly
horizontal across the plot. There are trends in both models that give
cause for concern. It appears that in both models as we move right along
the spread of the data points increases in a slight cone shape, with the
smaller end of the cone on the left and larger end on the right. This is
a problem that needs to be addressed before making real world policy
decisions. A Breusch-Pagan Test where the null hypothesis states that
residuals are homoscedastic and the alternative hypothesis is that the
residuals are heteroscedastic (there is an uneven spread of residuals)
would help solidify our findings.

## Conclusion

This project was an excellent test of my abilities using R as a
programming language and getting my feet wet in the field of statistical
research. I am sure that there are plenty of places where I could have
been more efficient, better optimized, or even had better ideas. But
that is not the point, the point was to get back on the horse of
econometric modeling and research. I will say that I genuinely enjoyed
the process and feel that I have expanded and reinforced my
understanding of statistical concepts.

I have been teaching myself to use R since February 2025. I would call
this project a success overall. I learned about linear regressions in R
(having only a STATA background), greatly expanded my abilities to do
EDA in R and visualize general trends with slick charts and graphs, and
learned how to create markdown files and compile all of my results in a
neatly organized document. The next step is getting this posted to
Github (if you are reading this you know I have completed that step).

From here I can either dive deeper into this data and re test my
hypothesis using a more granular education variable, or I can call this
a wash and move on to a whole new project. I will probably end up doing
both. In the mean time I need to brainstorm new projects to do in R.
