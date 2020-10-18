*&---------------------------------------------------------------------*
*& Report ZDEMO_PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*& DESCRIPTION: Reset runtime value to stop timeout
*&---------------------------------------------------------------------*
REPORT zdemo_progress_indicator.

TYPES: BEGIN OF t_vrsx,
         versno LIKE vrsx-versno,
       END OF t_vrsx.
DATA: it_vrsx TYPE STANDARD TABLE OF t_vrsx INITIAL SIZE 0,
      wa_vrsx TYPE t_vrsx.
DATA: gd_outtext(70) TYPE c.
*********************************************************
*START-OF-SELECTION.
START-OF-SELECTION.
  SELECT versno
   UP TO 1000 ROWS
    INTO TABLE it_vrsx
    FROM vrsx.
  CHECK sy-subrc EQ 0.
  LOOP AT it_vrsx INTO wa_vrsx.
    CONCATENATE 'Processing purchase order' wa_vrsx-versno INTO gd_outtext
            SEPARATED BY ' '.
    CALL FUNCTION 'TH_REDISPATCH'
*   EXPORTING
*     CHECK_RUNTIME       = 0
      .
*   Display indicator for ebeln count
    PERFORM progress_indicator USING gd_outtext.
  ENDLOOP.
  WRITE: /20 'Report "Complete" '.
*&---------------------------------------------------------------------*
*&      Form  PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*       Displays progress indicator on ABAP report
*----------------------------------------------------------------------*
FORM progress_indicator USING p_text.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      text = p_text.
ENDFORM.
