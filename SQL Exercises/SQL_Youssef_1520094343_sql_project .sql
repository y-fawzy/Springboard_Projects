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
 -Tennis Court 1
 -Tennis Court 2
 -Massage Room 1
 -Massage Room 2
 -Squash Court

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*) AS no_charge_facilities 
	FROM `Facilities`
	WHERE membercost = 0 
Result:
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
	

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
	FROM `Facilities`
 	WHERE facid BETWEEN 1 AND 5



/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name,
       monthlymaintenance,
	CASE WHEN monthlymaintenance > 100 THEN 'expensive'
	     ELSE 'cheap' END AS 'cheap/expensive'
FROM `Facilities` 


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname,
	   surname,
	   joindate 
FROM `Members`
ORDER BY joindate DESC
LIMIT 1

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
