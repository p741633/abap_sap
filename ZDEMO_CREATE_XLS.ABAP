*&---------------------------------------------------------------------*
*& Report ZDEMO_CREATE_XLS
*&---------------------------------------------------------------------*
*& DESCRIPTION: Create file on local system (SAP_CONVERT_TO_XLS_FORMAT)
*&---------------------------------------------------------------------*
REPORT zdemo_create_xls.

TYPES : BEGIN OF ty_vrsx,
          relid      LIKE vrsx-relid,
          objsubtype LIKE vrsx-objsubtype,
          objname    LIKE vrsx-objname,
          versno     LIKE vrsx-versno,
        END OF ty_vrsx.
* To hold selection data
DATA: it_vrsx TYPE STANDARD TABLE OF ty_vrsx WITH HEADER LINE.
* To hold converted text data
*DATA: i_text(4096) TYPE c OCCURS 0.

* Selection Screen
PARAMETERS: p_file LIKE rlgrap-filename DEFAULT 'test.xlsx'.
PARAMETERS: p_relid LIKE vrsx-relid DEFAULT 'CU'.

* Select data into an ITAB based on the selection Criteria
SELECT relid, objsubtype, objname, versno
    FROM vrsx
    INTO TABLE @it_vrsx
    UP TO 5 ROWS
    WHERE relid = @p_relid.

* Process further only if found some data
IF NOT it_vrsx[] IS INITIAL.
* Convert data in internal table to a delimited text data
  CALL FUNCTION 'SAP_CONVERT_TO_XLS_FORMAT'
    EXPORTING
      i_field_seperator = 'X'
      i_line_header     = 'X'
      i_filename        = p_file
    TABLES
      i_tab_sap_data    = it_vrsx
*    CHANGING
*     i_tab_converted_data = i_text
    EXCEPTIONS
      conversion_failed = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    WRITE: / 'Program failed to Convert data.'.
  ELSE.
    WRITE: 'Download completed.'.
* Download convert data to Presentation Server
*    CALL FUNCTION 'DOWNLOAD'
*      TABLES
*        data_tab = i_text
*      EXCEPTIONS
*        OTHERS   = 8.
*    IF sy-subrc <> 0.
*      WRITE: / 'Program failed to download data.'.
*    ENDIF.
  ENDIF.
ELSE.
  WRITE: / 'No data found.'.
ENDIF.