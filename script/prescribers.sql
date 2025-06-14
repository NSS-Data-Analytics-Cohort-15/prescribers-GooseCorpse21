-- 1. 
-- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT p.npi, (pr.total_claim_count)
FROM prescriber AS p
LEFT JOIN prescription AS pr
USING(npi)
WHERE pr.total_claim_count IS NOT NULL
GROUP BY p.npi,pr.total_claim_count
ORDER BY pr.total_claim_count DESC; -- npi: 1912011792; claims: 4538

-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  
-- specialty_description, and the total number of claims.
SELECT p.nppes_provider_first_name, p.nppes_provider_last_org_name, p.specialty_description, pr.total_claim_count
FROM prescriber AS p
LEFT JOIN prescription AS pr
USING(npi)
WHERE pr.total_claim_count IS NOT NULL
GROUP BY p.nppes_provider_first_name, p.nppes_provider_last_org_name, p.specialty_description ,pr.total_claim_count
ORDER BY pr.total_claim_count DESC -- DAVID COFFEY; FAMILY PRACTICE; 4538

-- 2. 
   -- a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT p.specialty_description, SUM(pr.total_claim_count)
FROM prescription AS pr
LEFT JOIN prescriber AS p
USING(npi)
GROUP BY p.specialty_description, pr.total_claim_count
ORDER BY pr.total_claim_count DESC -- Nurse Practitioner

   -- b. Which specialty had the most total number of claims for opioids?
SELECT DISTINCT( p.specialty_description), COUNT(pr.total_claim_count)
FROM prescriber AS p
INNER JOIN prescription AS pr
USING(npi)
WHERE p.specialty_description LIKE 'opioid'
GROUP BY p.specialty_description, pr.total_claim_count
ORDER BY COUNT(pr.total_claim_count) DESC 

-- JENNIFERS CODE
SELECT DISTINCT prescriber.specialty_description, SUM(prescription.total_claim_count) AS highest_claim_total
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
INNER JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description, drug.opioid_drug_flag
ORDER BY 2 DESC
LIMIT 1;

-- 3. 
   -- a. Which drug (generic_name) had the highest total drug cost?
SELECT d.generic_name, p.total_drug_cost
FROM drug AS d
INNER JOIN prescription AS p
USING(drug_name)
GROUP BY d.generic_name, total_drug_cost
ORDER BY p.total_drug_cost DESC
LIMIT 1

   -- b. Which drug (generic_name) has the hightest total cost per day?
-- DIBRANS CODE
SELECT generic_name, SUM(total_drug_cost) / SUM(total_day_supply) AS total_cost_per_day
FROM prescription
INNER JOIN drug
USING(drug_name)
GROUP BY generic_name
ORDER BY total_cost_per_day;

-- 4. 
   -- a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which
   -- have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 



   -- b. Building off of the query you wrote for part a, determine whether more was spent
   -- (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
-- JENNIFERS CODE
SELECT
    CASE
        WHEN drug.opioid_drug_flag = 'Y' THEN 'opioid'
        WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
        ELSE 'neither'
    END AS drug_type,  
    SUM(prescription.total_drug_cost)::MONEY AS total_spent -- Postgres specific cast to the money data type
FROM
    drug 
INNER JOIN prescription 
Using(drug_name)
WHERE drug.opioid_drug_flag = 'Y' OR drug.antibiotic_drug_flag = 'Y'
GROUP BY drug_type
ORDER BY total_spent DESC;

-- 5. 
   -- a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
-- CAMI AND DIBRANS CODE
SELECT COUNT(cbsa)
FROM cbsa
INNER JOIN fips_county
USING(fipscounty)
WHERE state = 'TN';

-- CASSIDY CODE
SELECT COUNT(*)
FROM cbsa
WHERE cbsaname LIKE '%TN%';

  -- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
-- CHRISTIANA CODE
(SELECT cbsaname, SUM(population), 'smallest' as flag
FROM cbsa
INNER JOIN population
ON cbsa.fipscounty = population.fipscounty
GROUP BY cbsaname
ORDER BY SUM(population) ASC
LIMIT 1)
UNION 
(SELECT cbsaname, SUM(population), 'largest' as flag
FROM cbsa
INNER JOIN population
ON cbsa.fipscounty = population.fipscounty
GROUP BY cbsaname
ORDER BY SUM(population) DESC
LIMIT 1 )
-- OR
SELECT cbsaname, SUM(population)
FROM cbsa
INNER JOIN population
ON cbsa.fipscounty = population.fipscounty
GROUP BY cbsaname
ORDER BY SUM(population) ASC;
   -- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
