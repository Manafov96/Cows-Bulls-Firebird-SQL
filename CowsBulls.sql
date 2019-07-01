-----------------------FIND MY NUMBERS USING COWS AND BULLS---------------------------------
/******************************************************************************/
/***                    Author Selvi Manafov                                 **/
/******************************************************************************/

SET SQL DIALECT 3;

SET NAMES UTF8;

CREATE DATABASE 'D:\COWS_BULLS.FDB'
USER 'SYSDBA' PASSWORD 'masterkey'
PAGE_SIZE 16384
DEFAULT CHARACTER SET UTF8 COLLATION UNICODE_CI;

---------------------------------Create table MY$NUMBERS---------------------------------------------------

CREATE GENERATOR MY$NUMBERS_GEN;
CREATE DOMAIN DM_PK  AS BIGINT;
CREATE DOMAIN DM_SMALL AS SMALLINT;

COMMENT ON DOMAIN DM_PK IS 'DOMAIN FOR PRIMARY KEY (ID)';
COMMENT ON DOMAIN DM_SMALL IS 'DOMAIN FOR SMALLINT NUMBERS';

CREATE TABLE MY$NUMBERS (
    ID      DM_PK NOT NULL /* DM_PK = BIGINT NOT NULL */,
    NUMBER  DM_SMALL /* DM_SMALL = SMALLINT */
);

ALTER TABLE MY$NUMBERS ADD CONSTRAINT PK_MY$NUMBERS PRIMARY KEY (ID);

SET TERM ^ ;

CREATE OR ALTER TRIGGER MY$NUMBERS_BI FOR MY$NUMBERS
ACTIVE BEFORE INSERT POSITION 0
AS
begin
  if(new.ID is null)then
    new.ID = gen_id(MY$NUMBERS_GEN,1);
end
^

SET TERM ; ^

COMMENT ON TABLE MY$NUMBERS IS 
'Table for all 4 digits numbers with distinct digits.';

COMMENT ON COLUMN MY$NUMBERS.ID IS 
'Field for primary key (ID)';

COMMENT ON COLUMN MY$NUMBERS.NUMBER IS 
'Field for my Numbers';
------------------------------------------------------------------------------------------------------------------------
------------------------------------------Create Exception--------------------------------------------------------------

CREATE EXCEPTION EX 'EXCEPTION FOR TABLE MY$NUMBERS';

COMMENT ON EXCEPTION EX IS 
'EXCEPTION FOR TABLE MY$NUMBERS';
------------------------------------------------------------------------------------------------------------------------
--------------------------------------Procedure Insert Numbers----------------------------------------------------------
SET TERM ^ ;

create or alter procedure INSERT_NUMBERS
as
declare variable COUNTER smallint;
declare variable POS1 smallint;
declare variable POS2 smallint;
declare variable POS3 smallint;
declare variable POS4 smallint;
declare variable STMT varchar(1000);
begin

  delete from MY$NUMBERS N
  where N.NUMBER > 0;

  STMT = 'ALTER SEQUENCE MY$NUMBERS_GEN RESTART WITH 0';
  execute statement (STMT);

  COUNTER = 1022;
  POS1 = 0;
  POS2 = 0;
  POS3 = 0;
  POS4 = 0;

  while(COUNTER <=  9875) do
  begin
    COUNTER = COUNTER + 1;

    POS1 = mod((COUNTER/ 1000), 10);
    POS2 = mod((COUNTER/ 100), 10);
    POS3 = mod((COUNTER/ 10), 10);
    POS4 = mod(COUNTER, 10);

    if(POS1 <> POS2 and POS1 <> POS3 and POS1 <> POS4 and POS2 <> POS3 and POS2 <> POS4 and POS3 <> POS4) then
      insert into MY$NUMBERS (NUMBER) values(:COUNTER);
  end
end
^

SET TERM ; ^


------------------------------------------------------------------------------------------------------------------------
-----------------------------------------Procedure Cows and Bulls-------------------------------------------------------
SET TERM ^ ;
create or alter procedure COWS_BULLS (
    MYNUMBER smallint,
    YOURNUMBER smallint)
returns (
    NUMBER smallint,
    COWS smallint,
    BULLS smallint,
    POSITION1 smallint,
    POSITION2 smallint,
    POSITION3 smallint,
    POSITION4 smallint)
as
declare variable SETNUMBER smallint;
declare variable POSITION11 smallint;
declare variable POSITION21 smallint;
declare variable POSITION31 smallint;
declare variable POSITION41 smallint;
begin
  BULLS = 0;
  COWS = 0;
  NUMBER = :MYNUMBER;

  -- MyNumber positions
   POSITION1 = mod((:MYNUMBER/ 1000), 10);
   POSITION2 = mod((:MYNUMBER/ 100), 10);
   POSITION3 = mod((:MYNUMBER/ 10), 10);
   POSITION4 = mod(:MYNUMBER, 10);


  -- YourNumber position
   POSITION11 = mod((:YourNumber/ 1000), 10);
   POSITION21 = mod((:YourNumber/ 100), 10);
   POSITION31 = mod((:YourNumber/ 10), 10);
   POSITION41 = mod(:YourNumber, 10);

  -- Checks
  if(POSITION11 = POSITION21 or (POSITION11 = POSITION31) or (POSITION11 = POSITION41) or (POSITION21 = POSITION41) or
     (POSITION31 = POSITION41) or (POSITION21 = POSITION31) ) then
    exception ex 'You cannot enter number with repeat digits!!!';

  -- position1
  if(POSITION1 = POSITION11) then
    BULLS = BULLS + 1;
  if(POSITION1 = POSITION21) then
    COWS = COWS + 1;
  if(POSITION1 = POSITION31) then
    COWS = COWS + 1;
  if(POSITION1 = POSITION41) then
    COWS = COWS + 1;

  -- position2
  if(POSITION2 = POSITION21) then
    BULLS = BULLS + 1;
  if(POSITION2 = POSITION11) then
    COWS = COWS + 1;
  if(POSITION2 = POSITION31) then
    COWS = COWS + 1;
  if(POSITION2 = POSITION41) then
    COWS = COWS + 1;

   --position3
  if(POSITION3 = POSITION31) then
    BULLS = BULLS + 1;
  if(POSITION3 = POSITION21) then
    COWS = COWS + 1;
  if(POSITION3 = POSITION11) then
    COWS = COWS + 1;
  if(POSITION3 = POSITION41) then
    COWS = COWS + 1;

   --position4
  if(POSITION4 = POSITION41) then
    BULLS = BULLS + 1;
  if(POSITION4 = POSITION21) then
    COWS = COWS + 1;
  if(POSITION4 = POSITION31) then
    COWS = COWS + 1;
  if(POSITION4 = POSITION11) then
    COWS = COWS + 1;

  suspend;
end
^

SET TERM ; ^
------------------------------------------------------------------------------------------------------------------------
---------------------------------------Procedure Compare Numbers--------------------------------------------------------
SET TERM ^ ;
create or alter procedure COMPARE_NUMBERS (
    YOURNUMBER smallint)
returns (
    MYNUMBER smallint,
    COWS smallint,
    BULLS smallint)
as
declare variable STMT varchar(1000);
declare variable POS1 smallint;
declare variable POS2 smallint;
declare variable POS3 smallint;
declare variable POS4 smallint;
begin
  BULLS = 0;
  COWS = 0;
  STMT = '';
    -- Check for number
  if(YOURNUMBER < 1000 or (YOURNUMBER > 9999)) then
    exception ex 'Number can be only 4 digits!!!';

  -- Check if all numbers are in the table
  if((select count(0) from MY$NUMBERS) < 4536) then
    exit;

  -- Compare with first number
  STMT = 'select
             first 1 N.NUMBER
          from
             MY$NUMBERS N
          order by
             N.NUMBER';
  execute statement (STMT) into MYNUMBER;
  select
    CN.NUMBER, CN.COWS, CN.BULLS, CN.POSITION1, CN.POSITION2, CN.POSITION3, CN.POSITION4
  from
    COWS_BULLS(:MYNUMBER, :YOURNUMBER) CN
  into
    :MYNUMBER, :COWS, :BULLS, :POS1, :POS2, :POS3, :POS4;
  suspend;
  -- Loop for find Your Number. When bulls = 4 then this is Your Number
  while(BULLS <> 4) do
  begin
  -- Check when we have 0 bulls
  if(BULLS = 0) then
  begin
    delete from MY$NUMBERS N where  -- example 4321
    N.NUMBER like :POS1 || '___' or              -- 4xxx
    N.NUMBER like '_' || :POS2 || '__' or        -- x3xx
    N.NUMBER like '__' || :POS3 || '_' or        -- xx2x
    N.NUMBER like '___' || :POS4;                -- xxx1

  execute statement (STMT) into MYNUMBER;
  select
    CN.NUMBER, CN.COWS, CN.BULLS, CN.POSITION1, CN.POSITION2, CN.POSITION3, CN.POSITION4
  from
    COWS_BULLS(:MYNUMBER, :YOURNUMBER) CN
  into
    :MYNUMBER, :COWS, :BULLS, :POS1, :POS2, :POS3, :POS4;
  suspend;

  end
  -- Check when we have 1 bulls
  if(BULLS = 1) then
  begin
    delete from MY$NUMBERS N where        -- example 4321
    N.NUMBER like :POS1 || :POS2 || '__' or        --43xx
    N.NUMBER like :POS1 || '_' || :POS3 || '_' or  --4x2x
    N.NUMBER like :POS1 || '__' || :POS4 or        --4xx1
    N.NUMBER like '_' || :POS2 || :POS3 || '_' or  --x23x
    N.NUMBER like '_' || :POS2 || '_' || :POS4 or  --x3x1
    N.NUMBER like '__' || :POS3 || :POS4;          --xx21

  execute statement (STMT) into MYNUMBER;
  select
    CN.NUMBER, CN.COWS, CN.BULLS, CN.POSITION1, CN.POSITION2, CN.POSITION3, CN.POSITION4
  from
    COWS_BULLS(:MYNUMBER, :YOURNUMBER) CN
  into
    :MYNUMBER, :COWS, :BULLS, :POS1, :POS2, :POS3, :POS4;
  suspend;

  end
  -- Check when we have 2 bulls
  if(BULLS = 2) then
  begin
    delete from MY$NUMBERS N where    -- example 4321
    N.NUMBER like :POS1 || :POS2 || :POS3 || '_' or  --432x
    N.NUMBER like '_' || :POS2 || :POS3 || :POS4 or  --x321
    N.NUMBER like :POS1 || :POS2 || '_' || :POS4 or  --43x1
    N.NUMBER like :POS1 || '_' || :POS3 || :POS4;    --4x21

  execute statement (STMT) into MYNUMBER;
  select
    CN.NUMBER, CN.COWS, CN.BULLS, CN.POSITION1, CN.POSITION2, CN.POSITION3, CN.POSITION4
  from
    COWS_BULLS(:MYNUMBER, :YOURNUMBER) CN
  into
    :MYNUMBER, :COWS, :BULLS, :POS1, :POS2, :POS3, :POS4;
  suspend;

  end
  -- Check when we have 3 bulls
  if(BULLS = 3) then
  begin
   delete from MY$NUMBERS N where   -- example 4321
   N.NUMBER = :MYNUMBER;            -- delete only 4321

  execute statement (STMT) into MYNUMBER;
  select
    CN.NUMBER, CN.COWS, CN.BULLS, CN.POSITION1, CN.POSITION2, CN.POSITION3, CN.POSITION4
  from
    COWS_BULLS(:MYNUMBER, :YOURNUMBER) CN
  into
    :MYNUMBER, :COWS, :BULLS, :POS1, :POS2, :POS3, :POS4;
  suspend;

  end

  end
  execute procedure INSERT_NUMBERS;
end
^

SET TERM ; ^


------------------------------------------------------------------------------------------------------------------------
-----------------------------------COMMENT AND INDEX--------------------------------------------------------------------

COMMENT ON PROCEDURE COMPARE_NUMBERS IS 'PROCEDURE FOR FIND YOUR NUMBER USING COWS AND BULLS';
COMMENT ON PROCEDURE COWS_BULLS IS 'PROCEDURE FOR RETURN HOW MANY COWS AND BULLS WE HAVE';
COMMENT ON PROCEDURE INSERT_NUMBERS IS 'PROCEDURE FOR CLEAN TABLE MY$NUMBERS ALL INSERT ALL 4 DIGITS NUMBERS WITH DISTINCT DIGITS';
COMMENT ON GENERATOR MY$NUMBERS_GEN IS 'GENERATOR FOR ID ON TABLE MY$NUMBERS';
COMMENT ON TRIGGER MY$NUMBERS_BI IS 'TRIGGER FOR GENERATE ID ON TABLE MY$NUMBERS';
CREATE INDEX MY$NUMBERS_IDX1
ON MY$NUMBERS (NUMBER);
SET STATISTICS INDEX PK_MY$NUMBERS;
------------------------------------------------------------------------------------------------------------------------
execute procedure INSERT_NUMBERS;
commit;
