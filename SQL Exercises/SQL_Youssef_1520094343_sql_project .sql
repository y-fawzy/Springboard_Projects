/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT * 
	FROM `Facilities` 
	WHERE membercost != 0
Result:

facid	name	membercost	guestcost	initialoutlay	monthlymaintenance	
0	Tennis Court 1	5.0	25.0	10000	200
1	Tennis Court 2	5.0	25.0	8000	200
4	Massage Room 1	9.9	80.0	4000	3000
5	Massage Room 2	9.9	80.0	4000	3000
6	Squash Court	3.5	17.5	5000	80


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*) AS no_charge_facilities 
	FROM `Facilities`
	WHERE membercost = 0 
Result:


no_charge_facilities
4


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT  facid AS 'Facility ID',
	name AS 'Facility Name', 
	membercost AS 'Member Cost',
	monthlymaintenance AS 'Monthly Maintenance'
   FROM `Facilities`
   WHERE membercost < 0.2*monthlymaintenance	
	
Result:

Facility ID	Facility Name	Member Cost	Monthly Maintenance	
0		Tennis Court 1 	5.0		200
1		Tennis Court 2	5.0		200
2		Badminton Court	0.0		50
3		Table Tennis	0.0		10
4		Massage Room 1	9.9		3000
5		Massage Room 2	9.9		3000
6		Squash Court	3.5		80
7		Snooker Table	0.0		15
8		Pool Table	0.0		15

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
	FROM `Facilities`
 	WHERE facid BETWEEN 1 AND 5

Result:

facid	name	membercost	guestcost	initialoutlay	monthlymaintenance	
1	Tennis Court 2	5.0	25.0	8000	200
2	Badminton Court	0.0	15.5	4000	50
3	Table Tennis	0.0	5.0	320	10
4	Massage Room 1	9.9	80.0	4000	3000
5	Massage Room 2	9.9	80.0	4000	3000


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name,
       monthlymaintenance,
	CASE WHEN monthlymaintenance > 100 THEN 'expensive'
	     ELSE 'cheap' END AS 'cheap/expensive'
FROM `Facilities` 

Result:

name	monthlymaintenance	cheap/expensive	
Tennis Court 1	200	expensive
Tennis Court 2	200	expensive
Badminton Court	50	cheap
Table Tennis	10	cheap
Massage Room 1	3000	expensive
Massage Room 2	3000	expensive
Squash Court	80	cheap
Snooker Table	15	cheap
Pool Table	15	cheap


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname,
	   surname,
	   joindate 
FROM `Members`
ORDER BY joindate DESC
LIMIT 1

Result:


firstname	surname	joindate	
Darren	Smith	2012-09-26 18:08:45


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */


SELECT     CONCAT(Members.firstname,' ', Members.surname) AS full_name,
	   Bookings.memid,
	   Bookings.facid,
	   Facilities.name AS court_name
FROM Bookings
LEFT JOIN Members
ON Bookings.memid = Members.memid
LEFT JOIN Facilities
ON Bookings.facid = Facilities.facid
WHERE Bookings.facid IN (0,1)
ORDER BY full_name

Result(First Few Rows):

full_name	memid	facid	court_name	
Anne Baker	12	1	Tennis Court 2
Anne Baker	12	0	Tennis Court 1
Anne Baker	12	1	Tennis Court 2
Anne Baker	12	1	Tennis Court 2
Anne Baker	12	0	Tennis Court 1
Anne Baker	12	1	Tennis Court 2
Anne Baker	12	1	Tennis Court 2
Anne Baker	12	0	Tennis Court 1


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT  Facilities.name AS 'Facility Name',
	CONCAT(Members.firstname,' ', Members.surname) AS 'Full Name',
	Bookings.starttime AS 'Time of Booking',
	CASE WHEN Bookings.memid=0 THEN Facilities.guestcost*Bookings.slots
	ELSE Facilities.membercost*Bookings.slots END AS 'Total Member Cost'
FROM Bookings
LEFT JOIN Members
ON Bookings.memid = Members.memid
LEFT JOIN Facilities
ON Bookings.facid = Facilities.facid
WHERE Bookings.starttime > '2012-09-14' 
AND Bookings.starttime < '2012-09-15' 
AND Facilities.guestcost*Bookings.slots  > 30
AND Facilities.membercost*Bookings.slots > 30
ORDER BY 4 DESC

Result:


Facility Name	Full Name	Time of Booking	Total Member Cost	
Massage Room 2	GUEST GUEST	2012-09-14 11:00:00	320.0
Massage Room 1	Jemima Farrell	2012-09-14 14:00:00	39.6


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT     Facilities.name,
 	   sub.*,
	   CASE WHEN sub.memid=0 THEN Facilities.guestcost*sub.slots
	   ELSE Facilities.membercost*sub.slots END AS 'Total Member Cost'
FROM  
	(SELECT Bookings.memid,
	   Bookings.facid, 
	   CONCAT(Members.firstname,' ', Members.surname) AS 'Full Name',
	   Bookings.starttime,
	   Bookings.slots
	FROM Bookings
	LEFT JOIN Members
	ON Bookings.memid = Members.memid
	WHERE Bookings.starttime > '2012-09-14' 
	AND Bookings.starttime < '2012-09-15') sub
LEFT JOIN Facilities
ON sub.facid = Facilities.facid
WHERE Facilities.guestcost*sub.slots  > 30
AND Facilities.membercost*sub.slots > 30
ORDER BY 7 DESC

Result:

name	memid	facid	Full Name	starttime	slots	Total Member Cost	
Massage Room 2	0	5	GUEST GUEST	2012-09-14 11:00:00	4	320.0
Massage Room 1	13	4	Jemima Farrell	2012-09-14 14:00:00	4	39.6

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */


SELECT Bookings.facid AS 'Facility ID',
	   Facilities.name AS 'Facility Name',
	   SUM(CASE WHEN Bookings.memid = 0 THEN slots*guestcost
           ELSE slots*membercost END) AS 'Total Revenue'
FROM Bookings
LEFT JOIN Facilities
ON Bookings.facid = Facilities.facid
GROUP BY 1,2
HAVING SUM(CASE WHEN Bookings.memid = 0 THEN slots*guestcost
           ELSE slots*membercost END) < 1000
ORDER BY 3 DESC

Result:

Facility ID	Facility Name	Total Revenue	
8	Pool Table	270.0
7	Snooker Table	240.0
3	Table Tennis	180.0
