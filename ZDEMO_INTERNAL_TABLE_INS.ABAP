*&---------------------------------------------------------------------*
*& Report ZDEMO_INTERNAL_TABLE_INS
*&---------------------------------------------------------------------*
*& DESCRIPTION: Populate data into internal table
*&---------------------------------------------------------------------*
REPORT zdemo_internal_table_ins.

DATA: BEGIN OF linv OCCURS 0,
        name(20)  TYPE c,
        id_number TYPE i,
      END OF linv.

DATA table1 LIKE TABLE OF linv.
linv-name = 'Melissa'.
linv-id_number = 105467.
APPEND linv TO table1.
LOOP AT table1 INTO linv.

  WRITE: / linv-name, linv-id_number.
ENDLOOP.
