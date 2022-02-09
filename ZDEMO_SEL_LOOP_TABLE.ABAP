*&---------------------------------------------------------------------*
*& Report ZDEMO_SEL_LOOP_TABLE
*&---------------------------------------------------------------------*
*& DESCRIPTION: Reading data from database table with loop
*&---------------------------------------------------------------------*
REPORT zdemo_sel_loop_table.

*objname(10) TYPE c,
TYPES : BEGIN OF ty_vrsx,
          relid      TYPE vrsx-relid,
          objsubtype TYPE vrsx-objsubtype,
          objname    TYPE vrsx-objname,
          versno     TYPE vrsx-versno,
        END OF ty_vrsx.

FIELD-SYMBOLS: <fs_vrsx> TYPE ty_vrsx.

DATA  : wa      TYPE ty_vrsx,
        it_vrsx TYPE TABLE OF ty_vrsx.

SELECT
  CAST( relid AS CHAR( 12 ) ) AS relid,
  objsubtype,
  objname,
  versno
  FROM vrsx
  INTO TABLE @it_vrsx.

*LOOP AT it_vrsx INTO wa.
LOOP AT it_vrsx ASSIGNING <fs_vrsx>.
  CONDENSE <fs_vrsx>-relid.
  CONDENSE <fs_vrsx>-objsubtype.
  CONDENSE <fs_vrsx>-objname.
  CONDENSE <fs_vrsx>-versno.
  WRITE:/ <fs_vrsx>-relid,',',<fs_vrsx>-objsubtype,',',<fs_vrsx>-objname,',',<fs_vrsx>-versno.
ENDLOOP.
