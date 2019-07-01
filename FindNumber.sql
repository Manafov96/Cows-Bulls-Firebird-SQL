-- Find my number
select
  CN.COWS, CN.BULLS
from
  COMPARE_NUMBERS (:NUMBER) CN
