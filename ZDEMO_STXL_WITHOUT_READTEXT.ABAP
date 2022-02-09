*&---------------------------------------------------------------------*
*& Report ZDEMO_STXL_WITHOUT_READTEXT
*&---------------------------------------------------------------------*
*& DESCRIPTION: Read STXL without read_text function
*&---------------------------------------------------------------------*
REPORT ZDEMO_STXL_WITHOUT_READTEXT.

TYPES: BEGIN OF ty_stxl,
          relid     TYPE stxl-relid,
          tdobject  TYPE stxl-tdobject,
          tdname    TYPE stxl-tdname,
          tdid      TYPE stxl-tdid,
          tdspras   TYPE stxl-tdspras,
          srtf2     TYPE stxl-srtf2,
          clustr    TYPE stxl-clustr,
          clustd    TYPE stxl-clustd,
        END OF ty_stxl.
DATA: t_stxl        TYPE STANDARD TABLE OF ty_stxl,
      t_stxl_buffer TYPE STANDARD TABLE OF ty_stxl.
FIELD-SYMBOLS: <stxl> TYPE ty_stxl.
* compressed text data without text name
TYPES: BEGIN OF ty_stxl_raw,
          clustr TYPE stxl-clustr,
          clustd TYPE stxl-clustd,
        END OF ty_stxl_raw.
DATA:  t_stxl_raw TYPE STANDARD TABLE OF ty_stxl_raw.
DATA:  w_stxl_raw TYPE ty_stxl_raw.
* decompressed text
DATA:  t_tline TYPE STANDARD TABLE OF tline.
FIELD-SYMBOLS: <tline> TYPE tline.
DATA: t_stxh TYPE STANDARD TABLE OF stxh,
       w_stxh TYPE stxh.
TABLES stxh.
SELECT-OPTIONS s_object FOR stxh-tdobject.
SELECT-OPTIONS s_name   FOR stxh-tdname.
SELECT-OPTIONS s_id     FOR stxh-tdid.
SELECT-OPTIONS s_langu  FOR stxh-tdspras.

SELECT tdname tdobject tdid tdspras
    FROM stxh
      INTO CORRESPONDING FIELDS OF TABLE t_stxh
    WHERE tdobject IN s_object
      AND tdname   IN s_name
      AND tdid     IN s_id
      AND tdspras  IN s_langu.

DATA s_stxl         TYPE ty_stxl.
DATA l_first_tabix  TYPE sy-tabix.
DATA l_last_tabix   TYPE sy-tabix.
DATA subrc          TYPE sy-subrc.
DATA process        TYPE abap_bool.
CONSTANTS package_size TYPE i VALUE 3000.

* select compressed text lines in blocks of 3000 (adjustable)
DATA cursor TYPE cursor.
OPEN CURSOR cursor FOR
SELECT relid tdobject tdname tdid tdspras srtf2 clustr clustd
        FROM stxl
        FOR ALL ENTRIES IN t_stxh "WITH APPLICATION DATA AND TDNAME
        WHERE relid    = 'TX'          "standard text
          AND tdobject = t_stxh-tdobject
          AND tdname   = t_stxh-tdname
          AND tdid     = t_stxh-tdid
          AND tdspras  = t_stxh-tdspras
        ORDER BY PRIMARY KEY. "<=== new

DO.
  FETCH NEXT CURSOR cursor
          APPENDING TABLE t_stxl
          PACKAGE SIZE package_size.
  subrc = sy-subrc.

  IF subrc = 4.
    IF lines( t_stxl ) > 0.
      process = abap_true.
    ELSE.
      process = abap_false.
    ENDIF.

  ELSEIF subrc = 0.
    IF lines( t_stxl ) < package_size.
      process = abap_true.
    ELSE.

      " put lines of last key aside, as there may be other lines for the same key
      DESCRIBE TABLE t_stxl LINES l_last_tabix.
      READ TABLE t_stxl INDEX l_last_tabix INTO s_stxl.
      READ TABLE t_stxl INDEX 1 ASSIGNING <stxl>.

      IF <stxl>-relid    = s_stxl-relid
            AND <stxl>-tdobject = s_stxl-tdobject
            AND <stxl>-tdname   = s_stxl-tdname
            AND <stxl>-tdid     = s_stxl-tdid
            AND <stxl>-tdspras  = s_stxl-tdspras.

        " The whole package has same key -> load next lines

        process = abap_false.

      ELSE.

        process = abap_true.

        l_first_tabix = l_last_tabix.
        l_first_tabix = l_last_tabix.
        DO.
          SUBTRACT 1 FROM l_first_tabix.
          READ TABLE t_stxl INDEX l_first_tabix ASSIGNING <stxl>.
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
          IF NOT ( <stxl>-relid    = s_stxl-relid
               AND <stxl>-tdobject = s_stxl-tdobject
               AND <stxl>-tdname   = s_stxl-tdname
               AND <stxl>-tdid     = s_stxl-tdid
               AND <stxl>-tdspras  = s_stxl-tdspras ).
            EXIT.
          ENDIF.
        ENDDO.

        ADD 1 TO l_first_tabix.
        APPEND LINES OF t_stxl FROM l_first_tabix TO l_last_tabix TO t_stxl_buffer.
        DELETE t_stxl FROM l_first_tabix TO l_last_tabix.

      ENDIF.
    ENDIF.
  ELSE.
    " can’t happen
    ASSERT 0 = 1.
  ENDIF.

  IF process = abap_true.
    LOOP AT t_stxl ASSIGNING <stxl>.

      AT NEW tdspras.
        REFRESH t_stxl_raw.
      ENDAT.

      " decompress text
      CLEAR w_stxl_raw.
      w_stxl_raw-clustr = <stxl>-clustr.
      w_stxl_raw-clustd = <stxl>-clustd.
      APPEND w_stxl_raw TO t_stxl_raw.

      AT END OF tdspras.
        IMPORT tline = t_tline FROM INTERNAL TABLE t_stxl_raw.
        DESCRIBE TABLE t_stxl_raw.
        FORMAT COLOR 5.
        WRITE: / 'AA', sy-tfill LEFT-JUSTIFIED, <stxl>-tdobject, <stxl>-tdname, <stxl>-tdid, <stxl>-tdspras.
        FORMAT RESET.
        LOOP AT t_tline ASSIGNING <tline>.
          WRITE: / <tline>-tdline.
        ENDLOOP.
        REFRESH t_stxl_raw.
      ENDAT.

    ENDLOOP.
  ENDIF.

  t_stxl = t_stxl_buffer.
  CLEAR t_stxl_buffer.

  IF subrc <> 0.
    EXIT.
  ENDIF.
ENDDO.

ASSERT 1 = 1. "(line for helping debug)