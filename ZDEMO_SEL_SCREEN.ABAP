*&---------------------------------------------------------------------*
*& Report Z102300
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z102300 NO STANDARD PAGE HEADING.

* comment
" comment
DATA gv_char01(20) TYPE c.  "comment
DATA gv_num01 TYPE i.
DATA gv_dec01 TYPE p DECIMALS 3.
DATA: gv_char02(10) TYPE c,
      gv_num02      TYPE i,
      gv_dec02      TYPE p DECIMALS 3.

DATA: gv_matnr TYPE mara-matnr,  "Material
      gv_matkl TYPE mara-matkl,  "Material Groyp
      gv_meins TYPE mara-meins,  "Base Unit of Measure
      gv_spart TYPE mara-spart.  "Division
TYPES: BEGIN OF gty_po,
         field01 TYPE i,
         field02 TYPE i,
         field03 TYPE i,
         field04 TYPE i,
         field05 TYPE i,
         meins   TYPE mara-meins,
         spart   TYPE mara-spart,
       END OF gty_po.

"Structure
DATA: gwa_po TYPE gty_po.

"Internal Table
DATA: gt_po TYPE TABLE OF gty_po WITH HEADER LINE.

"BREAK-POINT.
*BREAK 102300.

gv_char01 = 'TEST'.
gv_num01 = 10.
gv_dec01 = '2.645'.

gwa_po-field01 = 10.
gwa_po-field02 = 20.
gwa_po-field03 = 30.
gwa_po-field04 = 40.
gwa_po-field05 = 50.
gwa_po-meins = 'BOX'.
gwa_po-spart = '10'.

gt_po-field01 = 10.
gt_po-field02 = 20.
gt_po-field03 = 30.
gt_po-field04 = 40.
gt_po-field05 = 50.
APPEND gt_po.

gt_po-field01 = 100.
gt_po-field02 = 200.
gt_po-field03 = 300.
gt_po-field04 = 400.
gt_po-field05 = 500.
APPEND gt_po.

"WRITE: sy-uline.
***WRITE: sy-uline(58).
***WRITE: / sy-vline,gv_char01,sy-vline,gv_num01,sy-vline,gv_dec01,sy-vline.
***WRITE: sy-uline.
***WRITE: / sy-vline,gwa_po-field01,sy-vline,
***         gwa_po-field02,sy-vline,
***         gwa_po-field03,sy-vline,
***         gwa_po-field04,sy-vline,
***         gwa_po-field05,
***         sy-vline.
***WRITE: sy-uline.

**LOOP AT gt_po.
**  WRITE: / sy-vline,gt_po-field01,sy-vline,
**           gt_po-field02,sy-vline,
**           gt_po-field03,sy-vline,
**           gt_po-field04,sy-vline,
**           gt_po-field05,
**           sy-vline.
**ENDLOOP.
**WRITE: sy-uline.

TABLES  lfa1.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.
PARAMETERS pa_bukrs TYPE t001-bukrs DEFAULT '1000'.
SELECT-OPTIONS so_lifnr FOR lfa1-lifnr.
PARAMETERS: pa_date TYPE sy-datum OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-t02.
PARAMETERS: pa_sum RADIOBUTTON GROUP g01,
            pa_det RADIOBUTTON GROUP g01 DEFAULT 'X'.
PARAMETERS: pa_001 RADIOBUTTON GROUP g02,
            pa_002 RADIOBUTTON GROUP g02 DEFAULT 'X'.
PARAMETERS: pa_chk01 AS CHECKBOX,
            pa_chk02 AS CHECKBOX DEFAULT 'X',
            pa_chk03 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b02.

START-OF-SELECTION.
  DATA: gt_lfb1 TYPE TABLE OF lfb1 WITH HEADER LINE.
  BREAK gpoit05.

  SELECT * FROM lfb1 INTO TABLE gt_lfb1.

  SELECT lifnr bukrs akont FROM lfb1
    INTO CORRESPONDING FIELDS OF TABLE gt_lfb1.

  DATA: lv_lifnr TYPE lfb1-lifnr, "Vendor Code
        lv_bukrs TYPE lfb1-bukrs.  "Company Code

  SELECT SINGLE lifnr bukrs FROM lfb1
    INTO (lv_lifnr, lv_bukrs)
    WHERE lifnr IN so_lifnr  "Vendor Code
    AND bukrs = pa_bukrs.   "Company Code
  "ENDSELECT.
  DATA: lwa_lfb1 TYPE lfb1.  "Structure
  SELECT SINGLE lifnr bukrs akont FROM lfb1
    INTO CORRESPONDING FIELDS OF lwa_lfb1.
  BREAK gpoit05.

  "FREE gt_lfb1.
