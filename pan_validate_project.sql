select* from pan_no_dataset;

---Null values

select* from pan_no_dataset where pan_number is null;

---Duplicates

select pan_number,count(1)
from pan_no_dataset 
group by pan_number
having count (1)>1;

---Remove trailing/leading spaces

select* from pan_no_dataset where pan_number <> trim(pan_number)

---CORRECT LETTER CASE

select* from pan_no_dataset where pan_number <>upper(pan_number);

---Cleaned pan_numbers

select distinct UPPER(trim(pan_number) )AS pan_number
from pan_no_dataset
where pan_number is not null
and trim(pan_number)<> ''

---cleaned pans

SELECT DISTINCT 
       UPPER(TRIM(pan_number)) AS pan_number
FROM pan_no_dataset
WHERE pan_number IS NOT NULL

  AND TRIM(pan_number) <> ''
  
  --  PAN Format: 5 letters + 4 digits + 1 letter
  AND UPPER(TRIM(pan_number)) ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'
  
  --  Exclude adjacent same letters
  AND UPPER(TRIM(pan_number)) !~ '(.)\1{2,}'
  
  --  Exclude sequential alphabets
  AND UPPER(TRIM(pan_number)) !~ 'ABC|BCD|CDE|DEF|EFG|FGH|GHI|HIJ|IJK|JKL|KLM|LMN|MNO|NOP|OPQ|PQR|QRS|RST|STU|TUV|UVW|VWX|WXY|XYZ'
 
  --  Exclude sequential numbers
  AND UPPER(TRIM(pan_number)) !~ '012|123|234|345|456|567|678|789|890'
  
  --  Exclude adjacent same digits
  AND UPPER(TRIM(pan_number)) !~ '(\d)\1{2,}';




  -- Function to check if adjacent characters are repetative. 
-- Returns true if adjacent characters are adjacent else returns false
create or replace function fn_check_adjacent_repetition(p_str text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. (length(p_str) - 1)
	loop
		if substring(p_str, i, 1) = substring(p_str, i+1, 1)
		then 
			return true;
		end if;
	end loop;
	return false;
end;
$$



-- Function to check if characters are sequencial such as ABCDE, LMNOP, XYZ etc. 
-- Returns true if characters are sequencial else returns false
CREATE or replace function fn_check_sequence(p_str text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. (length(p_str) - 1)
	loop
		if ascii(substring(p_str, i+1, 1)) - ascii(substring(p_str, i, 1)) <> 1
		then 
			return false;
		end if;
	end loop;
	return true;
end;
$$


-- Valid Invalid PAN categorization
create or replace view vw_valid_invalid_pans 
as 
with cte_cleaned_pan as
		(select distinct upper(trim(pan_number)) as pan_number
		from pan_no_dataset 
		where pan_number is not null
		and TRIM(pan_number) <> ''),
	cte_valid_pan as
		(select *
		from cte_cleaned_pan
		where fn_check_adjacent_repetition(pan_number) = 'false'
		and fn_check_sequence(substring(pan_number,1,5)) = 'false'
		and fn_check_sequence(substring(pan_number,6,4)) = 'false'
		and pan_number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$')
select cln.pan_number
, case when vld.pan_number is null 
			then 'Invalid PAN' 
	   else 'Valid PAN' 
  end as status
from cte_cleaned_pan cln
left join cte_valid_pan vld on vld.pan_number = cln.pan_number;

	
-- Summary report
with cte as 
	(SELECT 
	    (SELECT COUNT(*) FROM pan_no_dataset) AS total_processed_records,
	    COUNT(*) FILTER (WHERE vw.status = 'Valid PAN') AS total_valid_pans,
	    COUNT(*) FILTER (WHERE vw.status = 'Invalid PAN') AS total_invalid_pans
	from  vw_valid_invalid_pans vw)
select total_processed_records, total_valid_pans, total_invalid_pans
, total_processed_records - (total_valid_pans+total_invalid_pans) as missing_incomplete_PANS
from cte;
  




