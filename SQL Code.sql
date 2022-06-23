# CREATE TABLES TO FILL THE DATABASE # 

create table house(
houseID int,
address varchar(100),
zipcode int,
primary key(houseID)
);

create table person(
personID int,
houseID int,
personName varchar(75),
phoneNumber int,
status int,
primary key(personID),
foreign key(houseID) references house
);

create table testResults(
personID int,
testDate date,
testResult int,
primary key(personID, testDate),
foreign key(personID) references person
);

create table events(
eventID int,
eventName varchar(75),
eventDate date,
eventAddress varchar(100),
primary key(eventID)
);

create table eventAttendance(
personID int,
eventID int,
primary key(personID, eventID),
foreign key(personID) references person,
foreign key(eventID) references events
);

create table flights(
flightID int,
flightDate date,
flightNumber varchar(50),
primary key(flightID)
);

create table personFlights(
personID int,
flightID int,
primary key(personID, flightID),
foreign key(personID) references person,
foreign key(flightID) references flights
);

# INSERT DATA INTO SAID TABLES # 

insert into house values(1, '100 Lane Street', 12345);
insert into house values(2, '101 Lane Street', 12346);
insert into house values(3, '102 Lane Street', 12347);

insert into person values(1, 1, 'David Saint', 1002005555, 0);
insert into person values(2, 2, 'David Seo', 3004005555, 1);
insert into person values(3, 3, 'Vincent T', 5006005555, 0);
insert into person values(4, 1, 'CJ Ude', 6006005555, 1);

insert into testResults values(1, date '2021-3-5', 1);
insert into testResults values(2, date '2021-3-5', 0);  
insert into testResults values(3, date '2021-3-5', 0);
insert into testResults values(1, date '2021-3-3', 0);

insert into events values(1, 'birthday party', date '2021-3-1',  '100 Lane Street');
insert into events values(2, 'friend gathering', date '2021-2-27',  '200 Lane Street');
insert into events values(3, 'visiting family', date '2021-3-3',  '001 Street Lane');

insert into eventAttendance values(1, 1);
insert into eventAttendance values(2, 2);
insert into eventAttendance values(3, 3);
insert into eventAttendance values(4,2);

insert into flights values(1, date '2021-3-3', 'R1000');
insert into flights values(2, date '2021-3-2', 'R1001');
insert into flights values(3, date '2021-3-1', 'R1002');

insert into personFlights values(2, 3);
insert into personFlights values(3, 3);
insert into personFlights values(3, 1);
insert into personFlights values(4, 2);


# Procedure 1 Code
# Add a new house to the database with exception handling to check if that house already exists
# Create sequence for new house ID, start at 4 since numbers 1-3 are already in the house table

set serveroutput on;
drop sequence new_houseID;
create sequence new_houseID
start with 4
increment by 1;

set serveroutput on;
create or replace procedure addHouse(user_address in varchar, user_zipcode in number)
is
cursor c1 is select address, zipcode from house;
ctr number;
ctrTwo number;
BEGIN
ctr := 0;
ctrTwo := 0;
for item in c1 loop
    if user_address = item.address and user_zipcode = item.zipcode and ctr = 0 then
        dbms_output.put_line('This house already exists!');
        ctr := ctr + 1;
    else
        if ctr = 0 then
            insert into house values(new_houseID.nextval, user_address, user_zipcode);
            ctr := ctr + 1;
        end if;
    end if;
end loop;
End;


# Procedure 2 Code
# Add a person to an existing house with exception handling to check if the person already exists or if the house exists

set serveroutput on;
create or replace procedure addPerson(person_ID in number, house_ID in number, pname in varchar,
phone_number in number)
is
invalidHouse number;
checkHouseID number;
checkPersonID number;
BEGIN
--select count to exception handling
select count(*) into invalidHouse from person where personname = pname and phonenumber = phone_number;
select count(*) into checkHouseID from person where houseid = house_ID;
select count(*) into checkPersonID from person where personid = person_ID;

if checkPersonID <> 0 then
    dbms_output.put_line('There is already a person with such ID');
elsif invalidHouse <> 0 then
    dbms_output.put_line('This person already exists!');
else
    if checkHouseID = 0 then 
        dbms_output.put_line('No such house exists!');
    else
        insert into person values(person_ID, house_ID, pname, phone_number, null);
    end if;
end if;
end;


# Procedure 3 Code
# Add a new test result

create or replace procedure newStatus(person_ID testResults.personID%type, test_Date testResults.testDate%type, v_result testResults.testResult%type)
is
counter_pid int;
counter_existing int;
begin
--checks to see if person exists
select count(*) into counter_pid from testResults where personID = person_ID;
--checks for an existing test
select count(*) into counter_existing from testResults where personID = person_ID and testDate = test_Date;
   
if counter_pid = 0 then
  dbms_output.put_line('Person does not exist');
  
--if there is already a test result then it updates it
elsif counter_existing > 0 then
  update testResults set testResult = v_result where personID = person_ID and testDate = test_Date;
  dbms_output.put_line('Result successfully changed');
  
--if test does not have a result then it adds one to the testResults table
else
  insert into testResults values(person_ID , test_Date, v_result);
end if;
end;


# Procedure 4 Code
# Update a persons status of if they are positive or negative with COVID-19

create or replace procedure updateStatus (v_personID in person.personID%type) 
is
v_result int;
v_maxdate date;
v_count int;  
begin
--select statements
select count(*) into v_count from person where personid = v_personID;

if v_count = 0 then
  dbms_output.put_line('Person does not exist');
else
--Tests for when a person does exist
  select max(testdate), count(*) into v_maxdate, v_count from testresults where personid = v_personid;  

if v_count = 0 then
  dbms_output.put_line('This person does not have any test results');
else
  select testresult into v_result from testresults where testdate = v_maxdate and personid = v_personid;
  update person set status = v_result where personid = v_personid;
end if;
end if;
end;


# Procedure 5 Code
# Add a new event

drop sequence event_id;
create sequence event_id
start with 4
increment by 1;

set serveroutput on;
create or replace procedure addEvents(event_name in varchar, event_date in date,
event_address in varchar)
is
checkEvent number;
BEGIN
select count(*) into checkEvent from events where event_name = eventname and event_date = eventdate
and event_address = eventaddress;

if checkEvent <> 0 then
    dbms_output.put_line('This event already exists!');
else
    insert into events values(event_id.nextval, event_name, event_date, event_address);
    dbms_output.put_line('Event ID: ' || event_id.currval);
end if;
END;


# Procedure 6 Code
# Print out individuals information for those whose current COVID-19 status is positive

create or replace procedure positive_people 
is
cursor c1 is select personname, phonenumber, zipcode from person p, house h where p.houseid = h.houseid and p.status = 1;
cursor c2 is select h.zipcode, count(h.zipcode) from house h, person p where p.status = 1 and h.houseid = p.houseid group by h.zipcode;

v_count int;
v_zipcode int;

BEGIN
for item in c1 loop
  dbms_output.put_line('Name: ' || item.personname || ' | Phone: ' || item.phonenumber || ' | Zipcode: ' 
  || item.zipcode);
end loop;

open c2;
loop
  fetch c2 into v_zipcode, v_count;
  exit when c2%notfound;
  dbms_output.put_line ('Zipcode: ' || v_zipcode || ' | Positive: ' || v_count);
end loop;
close c2;
END;


# Procedure 7 Code
# Enter a list of people attending an event with exception handling to check if the event exists, if the person exists, or if said person is already attending the event

create or replace type personListType as varray(80) of int;
/
create or replace procedure persons_attending(v_persons personListType, v_eventid int) as
v_count int;
BEGIN
select count(*) into v_count from events where eventid = v_eventid;

if v_count = 0 then
  dbms_output.put_line('Event does not exist');
else

if v_persons is not null then
  for i in 1..v_persons.count loop
  select count(*) into v_count from person where v_persons(i) = personid;
 
if v_count = 0 then
  dbms_output.put_line('This personid does not exist: ' || v_persons(i));
else

select count(*) into v_count from eventAttendance where v_persons(i) = personid and v_eventid = eventid;

if v_count != 0 then
  dbms_output.put_line('No need to insert personid: ' || v_persons(i));
else

insert into eventAttendance values(v_persons(i), v_eventid);
dbms_output.put_line('Inserted eventAttendance(' || v_persons(i) ||', '|| v_eventid ||')');
end if;
end if;
end loop;
else
dbms_output.put_line('v_persons is null');
end if;
end if;
END;


# Procedure 8 Code
# Given the name and phone number of a person, print out test dates and test results

set serveroutput on;
create or replace procedure printTestInfo(person_name in varchar, person_phone in number)
is
cursor c1 is select personname, testdate, testresult from person, testresults where
  person.personid = testresults.personid and person.personname = person_name and
  person.phonenumber = person_phone order by testdate desc;
 
check_person number;
check_result number;

BEGIN
select count(*) into check_person from person where personname = person_name and phonenumber = person_phone;
select count(*) into check_result from testresults t, person p where t.personid = p.personid and personname = person_name and phonenumber = person_phone;
if check_person = 0 then
	dbms_output.put_line('There is no person with given info');
elsif check_result = 0 then
	dbms_output.put_line('There are no previous results for this person');
else
	for item in c1 loop
    	dbms_output.put_line('Name: ' || item.personname || '| Test Date: ' || item.testdate || ' | Test Result: ' || item.testresult);
	end loop;
end if;
END;


# Procedure 9 Code
# Given an input date, print out the accumulated number of positive cases by that date

create or replace function cases_so_far (v_date_to_measure DATE)
    return int
as
    v_result int; 
BEGIN
select count(*) into v_resultfrom testResults where testDate <= v_date_to_measure and testResult = 1;
return v_result;
END cases_so_far;


# Procedure 10 Code
# Print out names, phone numbers, houseID, and status of people who live in the same house as aynone whose current COVID-19 status is positive

set serveroutput on;
create or replace procedure positive_house
is
cursor c1 is select houseid, personname, phonenumber, status from person;
cursor c2 is select houseid, personname, phonenumber, status from person where status = 1;
ctr int;
BEGIN
    dbms_output.put_line('People in the same house as someone who tested positive:');
    for item in c1 loop
    ctr := 0;
        for itemTwo in c2 loop
            if item.houseid = itemTwo.houseid and ctr = 0 then
            dbms_output.put_line('houseID:' || item.houseid || ' Name:' || item.personname || 
            ' Phonenumber:' || item.phonenumber || ' Status:' || item.status);
            ctr := ctr + 1;
            end if;
        end loop;
    end loop;
END; 


# Procedure 11 Code
# Given a start and end date, return individuals info of those who were in the same flight as someone who tested positive

create or replace procedure contact_tracing_flight(startDate date, endDate date) 
as
checkdate date;
v_personid int;
v_flightid int;
v_personname varchar(75);
v_phonenumber int;
v_status int;
flag int := 0;
cursor c1 is select pf.personid, pf.flightid from personFlights pf, person p where p.status = 1 and p.personid = pf.personid;
cursor c2 is select pe.personname, pe.phonenumber, pe.status into v_personname, v_phonenumber, v_status from person pe, personflights pf where pf.flightid = v_flightid and pf.personid = pe.personid;
BEGIN
  if startDate > endDate then
    dbms_output.put_line('Start date is after end date therefore invalid');
  else
    open c1;
    
  loop
    fetch c1 into v_personid, v_flightid;
    exit when c1%notfound;
    
  select flightdate into checkdate from flights where flightid = v_flightid;
  if checkdate >= startdate and checkdate <= enddate then
    open c2;
    loop
      fetch c2 into v_personname, v_phonenumber, v_status;
      exit when c2%notfound;  
      dbms_output.put_line('Name: ' || v_personname|| ' '|| ' | Phone Number: ' ||v_phonenumber|| ' '||' | Covid Status: ' || v_status|| ' ' || ' | FlightID: ' ||v_flightid);
    end loop;
    close c2;
    
  else
    flag := 1;
  end if;
  end loop;
  close c1;
  
  if flag = 1 then
    dbms_output.put_line('No flight within given timeframe');
    end if;
  end if;
END;


# Procedure 12 Code
# Given a start and end date, return individuals info of those who were in the same event as someone who tested positive

set serveroutput on;
create or replace procedure checkEvent(begin_date in date, end_date in date)
is
cursor c1 is select personname, phonenumber, status, events.eventID from person, events, eventattendance
where person.personid = eventattendance.personid and eventattendance.eventid = events.eventid;

cursor c2 is select personname, phonenumber, status, events.eventID from person, events, eventattendance
where person.personid = eventattendance.personid and eventattendance.eventid = events.eventid and

status = 1;
check_date number;
ctr int;
BEGIN
select count(*) into check_date from events where events.eventdate > begin_date and
events.eventdate < end_date;
if begin_date > end_date then
    dbms_output.put_line('Beginning date should not be after end date');
elsif check_date = 0 then
    dbms_output.put_line('There is no event between the two given dates');
else
    for item in c1 loop
    ctr := 0;
        for itemTwo in c2 loop
            if item.eventid = itemTwo.eventid and ctr = 0 then
                dbms_output.put_line('Name: ' || item.personname || ' Phonenumber: ' || item.phonenumber
                || ' Status: ' || item.status || ' EventID: ' || item.eventid);
                ctr := ctr + 1;
            end if;
        end loop;
    end loop;
end if;
END;


# Procedure 13 Code
# Return names of individuals who have recovered

create or replace procedure recovered_people 
as
cursor c1 is select p.personname from person p, testresults t where status = 0 and t.personid = p.personid and testresult = 1;
v_count int := 0;
v_personname varchar(75);

BEGIN
open c1;
loop
  fetch c1 into v_personname;
  exit when c1%notfound;
  dbms_output.put_line(v_personname || ' has recovered from covid-19.');
  v_count := 1;
  end loop;
close c1;

if v_count = 0 then
  dbms_output.put_line('No person whos current status is negative has tested positively to covid-19 before.');
end if;
END;

