# Covid-19 Database Design and SQL Procedures

## Overview
Designed a relational database where I created multiple tables linking them with primary-foreign key relationships. Afterwards, I created PL/SQL procedures to insert my own made up personal data with exception handling along with automating the process of querying data based on repetitive questions.

## Tools Used
* SQL Developer
* Oracle Database

## Tables
* House - The house that the individuals live in
* Person - Represents the individual and their info
* Test Results - Contains history of test results
* Events - Social gathering or party
* Event Attendance - See who went to which event
* Flights - Information regarding airplanes individuals took
* Person Flights - Contains information about who took which plane

## Procedures
* Procedure 1: Add a new house to the database with exception handling to check if that house already exists
* Procedure 2: Add a person to an existing house with exception handling to check if the person already exists or if the house exists
* Procedure 3: Add a new test result 
* Procedure 4: Update a persons status of if they are positive or negative with COVID-19
* Procedure 5: Add a new event
* Procedure 6: Print out individuals information for those whose current COVID-19 status is positive
* Procedure 7: Enter a list of people attending an event with exception handling to check if the event exists, if the person exists, or if said person is already attending the event
* Procedure 8: Given the name and phone number of a person, print out test dates and test results
* Procedure 9: Given an input date, print out the accumulated number of positive cases by that date
* Procedure 10: Print out names, phone numbers, houseID, and status of people who live in the same house as aynone whose current COVID-19 status is positive
* Procedure 11: Given a start and end date, return individuals info of those who were in the same flight as someone who tested positive
* Procedure 12: Given a start and end date, return individuals info of those who were in the same event as someone who tested positive
* Procedure 13: Return names of individuals who have recovered

## Files Contained
* SQL Code from text file 
