*&---------------------------------------------------------------------*
*& Report ZDEMO_INTERNAL_TABLE
*&---------------------------------------------------------------------*
*& DESCRIPTION: Example of internal table
*&---------------------------------------------------------------------*
REPORT zdemo_internal_table.

TYPES: BEGIN OF customerline,
         cust_id       TYPE c,
         cust_name(20) TYPE c,
       END OF customerline.

TYPES mytable TYPE SORTED TABLE OF customerline
WITH UNIQUE KEY cust_id.
WRITE:/'The mytable is an Internal Table'.
