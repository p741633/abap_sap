*&---------------------------------------------------------------------*
*& Report ZDEMO_PROGRESS_BAR
*&---------------------------------------------------------------------*
*& DESCRIPTION: Select and loop with progress bar
*&---------------------------------------------------------------------*
REPORT zdemo_progress_bar.

TYPES: BEGIN OF t_vrsx,
         versno LIKE vrsx-versno,
       END OF t_vrsx.
DATA: it_vrsx TYPE STANDARD TABLE OF t_vrsx INITIAL SIZE 0,
      wa_vrsx TYPE t_vrsx.
DATA: vrsx_lines TYPE i,
      gd_percent TYPE i.
**************************************************************
*START-OF-SELECTION.
START-OF-SELECTION.
  SELECT versno
    INTO TABLE it_vrsx
    FROM vrsx.
  CHECK sy-subrc EQ 0.
  vrsx_lines = sy-dbcnt.
  CLEAR: gd_percent.
  LOOP AT it_vrsx INTO wa_vrsx.
    PERFORM progress_bar USING 'Retrieving data...'(001)
                               sy-tabix
                               vrsx_lines.
*    WAIT UP TO 2 SECONDS.
  ENDLOOP.
  WRITE: /20 'Report is "Complete" OK'.
*&---------------------------------------------------------------------*
*&      Form  PROGRESS_BAR
*&---------------------------------------------------------------------*
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
* This check needs to be in otherwise when looping around big tables
* SAP will re-display indicator too many times causing report to run
* very slow. (No need to re-display same percentage anyway)
  IF w_percentage GT gd_percent OR p_tabix EQ 1.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = w_percentage
        text       = w_text.
    gd_percent = w_percentage.
  ENDIF.
ENDFORM.                    " PROGRESS_BAR
