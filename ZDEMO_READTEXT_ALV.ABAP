*&---------------------------------------------------------------------*
*& Report ZDEMO_READTEXT_ALV
*&---------------------------------------------------------------------*
*& DESCRIPTION: ALV Report with long text using read_text function
*&---------------------------------------------------------------------*
REPORT zdemo_readtext_alv.

DATA: it_lines TYPE STANDARD TABLE OF tline,
      wa_lines TYPE tline.
DATA: full_text TYPE string.

DATA:
  BEGIN OF fs_stxl,
    mandt    LIKE stxl-mandt,
    relid    LIKE stxl-relid,
    tdobject LIKE stxl-tdobject,
    tdname   LIKE stxl-tdname,
    tdid     LIKE stxl-tdid,
    tdspras  LIKE stxl-tdspras,
    srtf2    LIKE stxl-srtf2,
    clustr   LIKE stxl-clustr,
    clustd   LIKE stxl-clustd,
    longtext TYPE tdline,
  END OF fs_stxl.

TYPES: BEGIN OF ty_stxl,
         mandt    TYPE mandt,
         relid    TYPE sychar02,
         tdobject TYPE tdobject,
         tdname   TYPE tdobname,
         tdid     TYPE tdid,
         tdspras  TYPE spras,
         srtf2    TYPE sybin1,
         clustr   TYPE sybin2,
         clustd   TYPE stxldummy2,
         longtext TYPE tdline,
       END OF ty_stxl.
DATA: wa_stxl TYPE ty_stxl.

DATA:
  it_stxl LIKE
     TABLE OF
           fs_stxl WITH HEADER LINE.

TYPES: BEGIN OF ty_stxl_str,
         mandt    TYPE string,
         relid    TYPE string,
         tdobject TYPE string,
         tdname   TYPE string,
         tdid     TYPE string,
         tdspras  TYPE string,
         srtf2    TYPE string,
         clustr   TYPE string,
         longtext TYPE string,
       END OF ty_stxl_str.
DATA: it_stxl_str TYPE STANDARD TABLE OF ty_stxl_str,
      wa_stxl_str TYPE ty_stxl_str.

DATA: stxl_lines TYPE i,
      gd_percent TYPE i.

DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

wa_fieldcat-fieldname  = 'mandt'.    " Fieldname in the data table
wa_fieldcat-seltext_m  = 'Client'.   " Column description in the output
"wa_fieldcat-emphasize   = 'X'.
"wa_fieldcat-key         = 'X'.
"wa_fieldcat-col_pos     = 1.
"wa_fieldcat-outputlen   = 15.
"wa_fieldcat-do_sum      = 'X'.        "Display column total
"wa_fieldcat-no_zero     = 'X'.
"wa_fieldcat-datatype     = 'CURR'.
APPEND wa_fieldcat TO it_fieldcat.

wa_fieldcat-fieldname  = 'relid'.
wa_fieldcat-seltext_m  = 'COL_2'.
APPEND wa_fieldcat TO it_fieldcat.

wa_fieldcat-fieldname  = 'tdobject'.
wa_fieldcat-seltext_m  = 'Text object'.
APPEND wa_fieldcat TO it_fieldcat.

wa_fieldcat-fieldname  = 'tdname'.
wa_fieldcat-seltext_m  = 'Text Name'.
APPEND wa_fieldcat TO it_fieldcat.

wa_fieldcat-fieldname  = 'tdid'.
wa_fieldcat-seltext_m  = 'Text ID'.
APPEND wa_fieldcat TO it_fieldcat.

wa_fieldcat-fieldname  = 'tdspras'.
wa_fieldcat-seltext_m  = 'Language Key'.
APPEND wa_fieldcat TO it_fieldcat.

wa_fieldcat-fieldname  = 'srtf2'.
wa_fieldcat-seltext_m  = 'COL_7'.
APPEND wa_fieldcat TO it_fieldcat.

wa_fieldcat-fieldname  = 'clustr'.
wa_fieldcat-seltext_m  = 'COL_8'.
APPEND wa_fieldcat TO it_fieldcat.

wa_fieldcat-fieldname  = 'longtext'.
wa_fieldcat-seltext_m  = 'Data'.
APPEND wa_fieldcat TO it_fieldcat.

TABLES stxh.
SELECT-OPTIONS s_object FOR stxh-tdobject.
SELECT-OPTIONS s_name   FOR stxh-tdname.
SELECT-OPTIONS s_id     FOR stxh-tdid.
SELECT-OPTIONS s_langu  FOR stxh-tdspras.

*SELECT-OPTIONS: mats FOR mara-matnr OBLIGATORY.
*SELECT-OPTIONS:
*  s_versno FOR fs_stxl-versno.
*PARAMETERS: p_relid LIKE stxl-relid DEFAULT 'CU' OBLIGATORY.

*INITIALIZATION.
*  s_versno-low = '1'.
*  s_versno-high = '2'.
*  APPEND s_versno.

*AT SELECTION-SCREEN. .
*  IF s_versno-low = ' '.
*    MESSAGE i000(zkmessage).
*  ELSEIF s_versno-high = ' '.
*    MESSAGE i001(zkmessage).
*  ENDIF.

START-OF-SELECTION.
  SELECT
         l~mandt
         l~relid
         l~tdobject
         l~tdname
         l~tdid
         l~tdspras
         l~srtf2
         l~clustr
         l~clustd
    INTO TABLE it_stxl
    FROM stxl AS l
    JOIN stxh AS h
    ON h~tdobject = l~tdobject
       AND h~tdname   = l~tdname
       AND h~tdid     = l~tdid
    UP TO 5000 ROWS
    WHERE l~relid    = 'TX' " standard text
      AND h~tdobject IN s_object " 'EKPO'
      AND h~tdname   IN s_name " '450001216400010'
      AND h~tdid     IN s_id " 'F01'
      AND l~tdspras  IN s_langu. " sy-langu.

  IF NOT it_stxl[] IS INITIAL.
    stxl_lines = sy-dbcnt.
    CLEAR: gd_percent.

    LOOP AT it_stxl INTO wa_stxl.
      PERFORM progress_bar USING 'Retrieving data...'(001)
                                   sy-tabix
                                   stxl_lines.

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client                  = sy-mandt
          id                      = wa_stxl-tdid
          language                = 'E'
          name                    = wa_stxl-tdname
          object                  = wa_stxl-tdobject
        TABLES
          lines                   = it_lines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.

      CLEAR full_text.

      LOOP AT it_lines INTO wa_lines.
        CONCATENATE full_text wa_lines-tdline INTO full_text SEPARATED BY space.
      ENDLOOP.

      CONDENSE full_text.

      wa_stxl_str-mandt = wa_stxl-mandt.
      wa_stxl_str-relid = wa_stxl-relid.
      wa_stxl_str-tdobject = wa_stxl-tdobject.
      wa_stxl_str-tdname = wa_stxl-tdname.
      wa_stxl_str-tdid = wa_stxl-tdid.
      wa_stxl_str-tdspras = wa_stxl-tdspras.
      wa_stxl_str-srtf2 = wa_stxl-srtf2.
      wa_stxl_str-clustr = wa_stxl-clustr.
      wa_stxl_str-longtext = full_text.
      APPEND wa_stxl_str TO it_stxl_str.
    ENDLOOP.

    "CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
*       i_callback_program = gd_repid
*       i_callback_top_of_page   = 'TOP-OF-PAGE'  "see FORM
*       i_callback_user_command = 'USER_COMMAND'
*       i_grid_title  = outtext
*       is_layout     = gd_layout
        it_fieldcat   = it_fieldcat
*       it_special_groups  = gd_tabgroup
*       IT_EVENTS     = GT_XEVENTS
        i_save        = 'X'
*       is_variant    = z_template
      TABLES
        t_outtab      = it_stxl_str
      EXCEPTIONS
        program_error = 1
        OTHERS        = 2.

    "IF sy-subrc EQ 0.
    "MESSAGE 'Download successful' TYPE 'I'.
    "ENDIF.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    MESSAGE 'No data found' TYPE 'I'.
  ENDIF.


FORM progress_bar USING    p_value
                           p_tabix
                           p_nlines.
  DATA: w_text(40),
        w_percentage      TYPE p,
        w_percent_char(3).

  w_percentage = ( p_tabix / p_nlines ) * 100.
  w_percent_char = w_percentage.
  SHIFT w_percent_char LEFT DELETING LEADING ' '.
  CONCATENATE p_value w_percent_char '% Complete'(002) INTO w_text.

  IF w_percentage GT gd_percent OR p_tabix EQ 1.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = w_percentage
        text       = w_text.
    gd_percent = w_percentage.
  ENDIF.
ENDFORM.