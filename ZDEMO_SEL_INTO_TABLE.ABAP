*&---------------------------------------------------------------------*
*& Report ZDEMO_SEL_INTO_TABLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdemo_sel_into_table.

TYPES : BEGIN OF ty_vrsx,
          relid      TYPE vrsx-relid,
          objsubtype TYPE vrsx-objsubtype,
          objname    TYPE vrsx-objname,
          versno     TYPE vrsx-versno,
        END OF ty_vrsx.

DATA  : wa      TYPE ty_vrsx,
        it_vrsx TYPE TABLE OF ty_vrsx.

SELECT relid, objsubtype, objname, versno FROM vrsx INTO TABLE @it_vrsx.

READ TABLE it_vrsx INTO wa INDEX 999.
IF sy-subrc = 0.
  WRITE:/ wa-relid,',',wa-objsubtype,',',wa-objname,',',wa-versno.
ELSE.
  WRITE 'No Record Found'.
ENDIF.
