*&---------------------------------------------------------------------*
*& Report ZDEMO_READTEXT_CREATE_XLS
*&---------------------------------------------------------------------*
*& DESCRIPTION: Create xls on the local system with readtext function
*&---------------------------------------------------------------------*
REPORT zdemo_readtext_create_xls.

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

DATA : BEGIN OF it_heading OCCURS 0,
         text(15),
       END OF it_heading.
it_heading-text = 'mandt'.
APPEND it_heading.
it_heading-text = 'relid'.
APPEND it_heading.
it_heading-text = 'tdobject'.
APPEND it_heading.
it_heading-text = 'tdname'.
APPEND it_heading.
it_heading-text = 'tdid'.
APPEND it_heading.
it_heading-text = 'tdspras'.
APPEND it_heading.
it_heading-text = 'srtf2'.
APPEND it_heading.
it_heading-text = 'clustr'.
APPEND it_heading.
it_heading-text = 'clustd'.
APPEND it_heading.

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

    CALL FUNCTION 'TH_REDISPATCH'
      EXPORTING
        check_runtime = 0.

    DATA: v_usr_action TYPE i,
          v_path       TYPE string,
          v_fullpath   TYPE string,
          v_filename   TYPE string.

    CLEAR: v_usr_action,
           v_path,
           v_fullpath,
           v_filename.

    CALL METHOD cl_gui_frontend_services=>file_save_dialog
      EXPORTING
        window_title         = 'Please select the location'
        default_extension    = 'xls'
        default_file_name    = 'stxl'
        file_filter          = '*.xls'
      CHANGING
        filename             = v_filename
        path                 = v_path
        fullpath             = v_fullpath
        user_action          = v_usr_action
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        OTHERS               = 4.

    IF v_usr_action <> 0.
      EXIT.
    ENDIF.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = v_filename
        filetype                = 'ASC'
        write_field_separator   = 'X'
      TABLES
        data_tab                = it_stxl_str
        fieldnames              = it_heading[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.

    IF sy-subrc EQ 0.
      MESSAGE 'Download successful' TYPE 'I'.
    ENDIF.
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