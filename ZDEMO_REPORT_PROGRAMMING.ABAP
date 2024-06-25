*&---------------------------------------------------------------------*
*& Report ZDEMO_REPORT_PROGRAMMING
*&---------------------------------------------------------------------*
*& DESCRIPTION: Example of report programming
*&---------------------------------------------------------------------*
REPORT zdemo_report_programming.

*line-size 75
*line-count 30(3)
*no standard page heading.
TABLES: mara.
TYPES: BEGIN OF itab,
         matnr TYPE mara-matnr,
         mbrsh TYPE mara-mbrsh,
         meins TYPE mara-meins,
         mtart TYPE mara-mtart,
       END OF itab.

DATA: wa_ma TYPE itab,
      it_ma TYPE STANDARD TABLE OF itab.

SELECT-OPTIONS: mats FOR mara-matnr OBLIGATORY.

INITIALIZATION.
  mats-low = '1'.
  mats-high = '500'.

  APPEND mats.

AT SELECTION-SCREEN. .
  IF mats-low = ' '.
    MESSAGE i000(zkmessage).
  ELSEIF mats-high = ' '.
    MESSAGE i001(zkmessage).
  ENDIF.

TOP-OF-PAGE.
  WRITE:/ 'CLASSICAL REPORT CONTAINING GENERAL MATERIAL DATA FROM the TABLE mara' COLOR 7.
  ULINE.
  WRITE:/ 'MATERIAL' COLOR 1,

  24 'INDUSTRY' COLOR 2,
  38 'UNITS' COLOR 3,
  53 'MATERIAL TYPE' COLOR 4.
  ULINE.

END-OF-PAGE.

START-OF-SELECTION.
  SELECT matnr mbrsh meins mtart FROM mara
  INTO TABLE it_ma WHERE matnr IN mats.
  LOOP AT it_ma INTO wa_ma.
    WRITE:/  wa_ma-matnr,

    25 wa_ma-mbrsh,
    40 wa_ma-meins,
    55 wa_ma-mtart.
  ENDLOOP.

END-OF-SELECTION.

  ULINE.
  WRITE:/ 'CLASSICAL REPORT HAS BEEN CREATED' COLOR 7.
  ULINE.
  SKIP.
