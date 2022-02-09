*&---------------------------------------------------------------------*
*& Report ZDEMO_CREATE_TXT
*&---------------------------------------------------------------------*
*& CDESCRIPTION: Create file on local system (SAP_CONVERT_TO_TEXT_FORMAT)
*&---------------------------------------------------------------------*
REPORT zdemo_create_txt.

* Must be char if you use SAP_CONVERT_TO_TEXT_FORMAT
* SAP_CONVERT_TO_CSV_FORMAT will convert dates and cash values just fine, but not integers
TYPES : BEGIN OF ty_vrsx,
          relid(50)      TYPE c,
          objsubtype(50) TYPE c,
          objname(50)    TYPE c,
          versno(50)     TYPE c,
        END OF ty_vrsx.
* To hold selection data
DATA: it_vrsx TYPE STANDARD TABLE OF ty_vrsx.
* To hold converted text data
DATA: i_text(4096) TYPE c OCCURS 0.

* Selection Screen
PARAMETERS: p_relid LIKE vrsx-relid.

* Select data into an ITAB based on the selection Criteria
SELECT relid, objsubtype, objname, versno
    FROM vrsx
    INTO TABLE @it_vrsx
    UP TO 5 ROWS
    WHERE relid = @p_relid.

* Process further only if found some data
IF NOT it_vrsx[] IS INITIAL.

* Convert data in internal table to a delimited text data
  CALL FUNCTION 'SAP_CONVERT_TO_TEX_FORMAT'
    EXPORTING
      i_field_seperator    = ','
    TABLES
      i_tab_sap_data       = it_vrsx
    CHANGING
      i_tab_converted_data = i_text
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    WRITE: / 'Program failed to Convert data.'.
  ELSE.

* Download convert data to Presentation Server
    CALL FUNCTION 'DOWNLOAD'
      TABLES
        data_tab = i_text
      EXCEPTIONS
        OTHERS   = 8.
    IF sy-subrc <> 0.
      WRITE: / 'Program failed to download data.'.
    ENDIF.
  ENDIF.
ELSE.
  WRITE: / 'No data found.'.
ENDIF.
