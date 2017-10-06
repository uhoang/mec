questions <- c(
'Q_LANGUAGE' = 'Q_LANGUAGE: In which language do you prefer to take this survey? / Dans quelle langue préférez-vous effectuer cette enquête?',
'Q_AGESCREENER' = 'Q_AGESCREENER: How old are you?',
'h_AGE' = 'h_AGE: How old are you?',
'Q_PROVINCE' = 'Q_PROVINCE: Which province/territory do you currently live in?',
'Q_COMMUNITY' = 'Q_COMMUNITY: Please indicate which best describes where you live.',
'Q_CONDITION' = 'Q_CONDITION: Which of the following health conditions, if any, do you currently suffer from?','Q_CONDITION) Which of the following health conditions, if any, do you currently suffer from?',
'Q_REMEDY' = 'Q_REMEDY: You said you currently suffer from the following health condition(s). Of these, which do you currently take medication for?',
'Q_GENDER' = 'Q_GENDER: Are you...?',
'Q_PARENTS' = 'Q_PARENTS: Do you have children under the age of 18 living at home?',
'Q_ACTIVITY' = 'Q_ACTIVITY: How often do you engage in the following?',
'Q_PURCHASE' = 'Q_PURCHASE: When is the last time you purchased the following products?',
'Q_FREQUENCY' = 'Q_FREQUENCY: You said you have purchased the products listed below in the past. How often do you use each of the following nutritional products?',
'Q_SPEND' = 'Q_SPEND: In the past month, how much have you spent on vitamins, minerals, and health supplements?',
'Q_PREVENTION' = 'Q_PREVENTION: Which of the following health conditions, if any, are you concerned about preventing in the future?',
'Q_STATEMENTS' = 'Q_STATEMENTS: For each statement, please indicate your agreement on a scale of 1-7, where 1 means "disagree completely" and 7 means "agree completely".',
'Q_GOALS' = 'Q_GOALS: Which of the following statements best represents your personal wellness goal?',
'Q_MEDIA' = 'Q_MEDIA: Please select how often you usually do the following:',
'Q_AGESCREENER' = 'Q_AGESCREENER: How old are you?'
)


q_condition <- c('Q_CONDITIONr1' = 'Difficulty falling asleep',
 'Q_CONDITIONr2' = 'Fatigue/ lack of energy',
 'Q_CONDITIONr3' = 'High blood pressure/ Hypertension',
 'Q_CONDITIONr4' = 'Insomnia/ Difficulty staying asleep',
 'Q_CONDITIONr5' = 'Joint problems/ stiffness',
 'Q_CONDITIONr6' = 'Stress/ anxiety',
 'Q_CONDITIONr7' = 'Oral/ Dental/ Tooth problems',
 'Q_CONDITIONr8' = 'Weight concerns',
 'Q_CONDITIONr9' = 'Glaucoma, cataracts, or other vision-related ailments',
 'Q_CONDITIONr10' = 'Digestive complications',
 'Q_CONDITIONr11' = 'Heart condition',
 'Q_CONDITIONr12' = 'Respiratory condition',
 'Q_CONDITIONr13' = 'High cholesterol',
 'Q_CONDITIONr14' = 'Chronic pain',
 'Q_CONDITIONr15' = 'Diabetes',
 'Q_CONDITIONr16' = 'Some other condition(s)',
 'Q_CONDITIONr98' = 'None of the above')

q_prevention <- c(
   'Q_PREVENTIONr1' = 'Diabetes',
   'Q_PREVENTIONr2' = 'High blood pressure/ Hypertension',
   'Q_PREVENTIONr3' = 'Joint problems/ stiffness',
   'Q_PREVENTIONr4' = 'General illness - cold, flu, etc.',
   'Q_PREVENTIONr5' = 'Difficulty falling asleep',
   'Q_PREVENTIONr6' = 'Fatigue/ lack of energy',
   'Q_PREVENTIONr7' = 'Insomnia/ Difficulty staying asleep',
   'Q_PREVENTIONr8' = 'Stress/ anxiety',
   'Q_PREVENTIONr9' = 'Oral/ Dental/ Tooth problems',
   'Q_PREVENTIONr10' = 'Weight concerns',
   'Q_PREVENTIONr11' = 'Glaucoma, cataracts, or other vision-related ailments',
   'Q_PREVENTIONr12' = 'Digestive complications',
   'Q_PREVENTIONr13' = 'Heart condition',
   'Q_PREVENTIONr14' = 'Respiratory condition',
   'Q_PREVENTIONr15' = 'High cholesterol',
   'Q_PREVENTIONr16' = 'Chronic pain',
   'Q_PREVENTIONr17' = 'Some other condition(s)',
   'Q_PREVENTIONr98' = 'None of the above'
)

q_remedy <- c(
 'Q_REMEDYr1' = 'Difficulty falling asleep',
 'Q_REMEDYr2' = 'Fatigue/ lack of energy',
 'Q_REMEDYr3' = 'High blood pressure/ Hypertension',
 'Q_REMEDYr4' = 'Insomnia/ Difficulty staying asleep',
 'Q_REMEDYr5' = 'Joint problems/ stiffness',
 'Q_REMEDYr6' = 'Stress/ anxiety',
 'Q_REMEDYr7' = 'Oral/ Dental/ Tooth problems',
 'Q_REMEDYr8' = 'Weight concerns',
 'Q_REMEDYr9' = 'Glaucoma, cataracts, or other vision-related ailments',
 'Q_REMEDYr10' = 'Digestive complications',
 'Q_REMEDYr11' = 'Heart condition',
 'Q_REMEDYr12' = 'Respiratory condition',
 'Q_REMEDYr13' = 'High cholesterol',
 'Q_REMEDYr14' = 'Chronic pain',
 'Q_REMEDYr15' = 'Diabetes',
 'Q_REMEDYr16' = 'Some other condition(s)',
 'Q_REMEDYr98' = 'None of the above'
)

q_statements <- c(
'Q_STATEMENTSr1' = 'Exercise is an essential part of my day',
'Q_STATEMENTSr2' = 'Friends and family often come to me for advice about how to eat well and/or be healthier',
'Q_STATEMENTSr3' = 'Health and wellness are important to me, but it can be overwhelming to try to do everything I should do',
'Q_STATEMENTSr4' = 'I am happy with my current life stage',
'Q_STATEMENTSr5' = 'I am trying to "fight" aging by staying healthy',
'Q_STATEMENTSr6' = 'I consider myself to be living a healthy lifestyle',
'Q_STATEMENTSr7' = "I don't stress over my nutrition or fitness level",
'Q_STATEMENTSr8' = "I eat what I want and don't pay attention to health benefits",
'Q_STATEMENTSr9' = 'I feel depressed about my current health status',
'Q_STATEMENTSr10' = 'I focus on getting the most out of every day',
'Q_STATEMENTSr11' = 'Life is complicated. I need simple solutions for my nutritional and health needs',
'Q_STATEMENTSr12' = 'My stress level has a negative impact on my daily life',
'Q_STATEMENTSr13' = 'Social media impacts what I eat and drink')

q_activity <- c(
'1' = 'Once a day or more',
'2' = '2-3 times a week',
'3' = 'Once a week',
'4' = 'A couple of times a month',
'5' = 'Once a month',
'6' = 'Once every 2-3 months',
'7' = 'Less often',
'8' = 'Never')

q_purchase <- c(
'1' = 'In the past month',
'2' = 'In the past 2-3 months',
'3' = 'In the past 6 months',
'4' = 'In the past year',
'5' = 'Longer ago than that',
'6' = 'Never')

q_frequency <- c(
  '1' = 'Once daily',
  '2' = 'Several days a week',
  '3' = 'Once a week',
  '4' = 'Once every two weeks',
  '5' = 'Once a month',
  '6' = 'Once every 2-3 months',
  '7' = 'Less often than that',
  '8' = 'Never'
)

q_spend <- c(
  '1' = '$0-25',
  '2' = '$26-50',
  '3' = '$51-75',
  '4' = '$76-100',
  '5' = '$101-125',
  '6' = '$126+',
  '7' = "Don't know"
)

q_media <- c(

  '1' = 'Once a day or more',
  '2' = 'Several days a week',
  '3' = 'Once a week',
  '4' = 'Once every two weeks',
  '5' = 'Once a month',
  '6' = 'Once every three months',
  '7' = 'Once every six months',
  '8' = 'Once a year',
  '9' = 'Less often',
  '10' = 'Never'
)


q_goals <- c(
  '1' = 'I want to maintain my current lifestyle without fear or discomfort.',
  '2' = 'I want to maintain my active lifestyle without feeling limited by pain.',
  '3' = 'I want to maintain a baseline of nutrition through easy to incorporate solutions.',
  '4' = 'I want to find a way to be productive and confident about my life and my health.',
  '5' = 'I want to fend off any and all potential health conditions, stay perfectly healthy forever.',
  '6' = "I want to be healthy enough that I don't have any bothersome issues.",
  '7' = 'I want to be able to continue being carefree about my health for as long as possible.'
  )

q_gender <- c(
  '1' = 'Male',
  '2' = 'Female',
  '100' = 'Other'
)

q_parents <- c(
  '1' = 'Yes',
  '2' = 'No'
)

q_community <- c(
  '1' = 'Urban/city centre',
  '2' = 'Large population centre',
  '3' = 'Medium population centre',
  '4' = 'Small population centre',
  '5' = 'Rural area'
)

h_province <- c(
  '1' = 'Ontario',
  '2' = 'Quebec',
  '3' = 'Atlantic Canada',
  '4' = 'West Canada'
)

q_language <- c(
  '1' = 'English',
  '2' = 'French'
)


q_activity_title <- c(
  'Q_ACTIVITYr1' = 'High intensity cardio activity',
  'Q_ACTIVITYr2' = 'Weightlifting or strength training',
  'Q_ACTIVITYr3' = 'Low intensity physical activity',
  'Q_ACTIVITYr4' = 'Competitive or recreational team sports',
  'Q_ACTIVITYr5' = 'Competitive or recreational individual sports'
)
  
q_purchase_title <- c(
  'Q_PURCHASEr1' = 'Multivitamins',
  'Q_PURCHASEr2' = 'Letter vitamin supplements',
  'Q_PURCHASEr3' = 'Mineral supplements',
  'Q_PURCHASEr4' = 'Fish oil and omegas',
  'Q_PURCHASEr5' = 'Meal replacements',
  'Q_PURCHASEr6' = 'Protein supplement',
  'Q_PURCHASEr7' = 'Weight loss supplements',
  'Q_PURCHASEr8' = 'Probiotics'
)
  
q_frequency_title <- c(
  'Q_FREQUENCYr1' = 'Multivitamins',
  'Q_FREQUENCYr2' = 'Letter vitamin supplements',
  'Q_FREQUENCYr3' = 'Mineral supplements',
  'Q_FREQUENCYr4' = 'Fish oil and omegas',
  'Q_FREQUENCYr5' = 'Meal replacements',
  'Q_FREQUENCYr6' = 'Protein supplement',
  'Q_FREQUENCYr7' = 'Weight loss supplements',
  'Q_FREQUENCYr8' = 'Probiotics'
)

q_media_title <- c(
  'Q_MEDIAr1' = 'Watch TV',
  'Q_MEDIAr2' = 'Listen to the radio',
  'Q_MEDIAr3' = 'Read a printed version of a newspaper',
  'Q_MEDIAr4' = 'Read a printed version of a magazine',
  'Q_MEDIAr5' = 'Go to the cinema / movie theatre',
  'Q_MEDIAr6' = 'Visit social media sites',
  'Q_MEDIAr7' = 'Use the internet for watching TV / video content',
  'Q_MEDIAr8' = 'Use the internet for listening to music, radio or podcasts',
  'Q_MEDIAr9' = 'Use the internet for looking at newspaper content',
  'Q_MEDIAr10' = 'Use a smartphone to access the internet',
  'Q_MEDIAr11' = 'Play video games',
  'Q_MEDIAr12' = 'Pass by large posters on the roadside or other large out of home advertising',
  'Q_MEDIAr13' = 'Pass by small posters on the street, at bus stops, in shopping malls, etc.',
  'Q_MEDIAr14' = 'Pass by advertising on or around public transportation',
  'Q_MEDIAr15' = 'Go to the doctor or a walk-in clinic',
  'Q_MEDIAr16' = 'Talk to a pharmacist',
  'Q_MEDIAr17' = 'Use a tablet to access the internet',
  'Q_MEDIAr18' = 'Use drugstore loyalty programs'
)


h_age <- c(
  '1' = '18-24',
  '2' = '25-34',
  '3' = '35-44',
  '4' = '45-54',
  '5' = '55-70'
)

q_province <- c(
  '1'='Ontario',
  '2'='Quebec',
  '3'='British Columbia',
  '4'='Alberta',
  '5'='Manitoba',
  '6'='Saskatchewan',
  '7'='Nova Scotia',
  '8'='New Brunswick',
  '9'='Newfoundland and Labrador',
  '10'='Prince Edward Island',
  '11'='Northwest Territories',
  '12'='Yukon',
  '13'='Nunavut',
  '14'='I do not live in Canada'
)