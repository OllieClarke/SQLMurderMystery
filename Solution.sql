-- find the crime report
WITH cr AS(
SELECT * 
FROM crime_scene_report
WHERE date='20180115'
AND type = 'murder'
AND city = 'SQL City')
/*witness is last house on Northwestern Dr or Annabel on Franklin Ave*/

  
-- Find witness 1
, wt1 AS(
SELECT *
FROM person
WHERE address_street_name ='Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1)

--Find witness 2
, wt2 as(
SELECT *
FROM person
WHERE name LIKE 'Annabel%' AND address_street_name = 'Franklin Ave')

--Both witnesses
, wta AS(
  SELECT * from wt1
  UNION 
  SELECT * from wt2)

--Get interview
, in1 AS(
SELECT person_id, transcript, name, license_id from interview
JOIN wta
ON person_id = id)
/* suspect is male, license including H42W, gold member at Get Fit Now gym where he worked out on Jan 9th */  

--find possible suspects from license plate
, sus AS(
SELECT a.id as license_id
  , age, height, eye_color, hair_color, plate_number, car_make, car_model
  , b.id as person_id, name, address_number, address_street_name, ssn
from drivers_license a
JOIN person b on a.id = b.license_id
WHERE plate_number LIKE '%H42W%' AND gender = 'male')

--Find suspect in gym
, gym1 AS(
SELECT * FROM get_fit_now_member a
JOIN sus on a.person_id = sus.person_id)

--Were they in the gym?
, gym2 AS(
SELECT * from get_fit_now_check_in
JOIN gym1 on membership_id = gym1.id)

--Culprit name
, sol as(
SELECT person_id, name
from gym2)
  /* Jeremy Bowers */

--Culprit interview
, in2 as(
SELECT *
from interview
JOIN sol on interview.person_id = sol.person_id)
  /*Hired by wealthy woman between 65" and 67". Red Hair, Tesla Model S and went to Sql Sympony 3 times in Dec 2017 */

--culture vulture
,sym AS (
SELECT person_id, COUNT(person_id) from facebook_event_checkin
WHERE date LIKE '201712%'
AND event_name LIKE '%SQL Symphony%'
GROUP BY person_id
HAVING COUNT(person_id) = 3)  

--Find actual culprit
SELECT name, person.id as person_id from drivers_license dl
JOIN person on dl.id = person.license_id
JOIN income on person.ssn = income.ssn
JOIN sym on person.id = sym.person_id
WHERE car_make = 'Tesla' AND car_model='Model S'
AND gender = 'female' AND hair_color = 'red'   
/* Miranda Priestly */

