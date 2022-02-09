*&---------------------------------------------------------------------*
*& Report ZDEMO_SEL_TABLE
*&---------------------------------------------------------------------*
*& DESCRIPTION: Select table and write to screen
*&---------------------------------------------------------------------*
REPORT zdemo_sel_table.

TABLES: vrsx.

SELECT * FROM vrsx.

*WRITE 'Hi'.

  WRITE: / vrsx-relid,',',vrsx-objsubtype,',',vrsx-objname,',',vrsx-versno,',',vrsx-srtf2,',',vrsx-clustr,',',vrsx-clustd.

ENDSELECT.
