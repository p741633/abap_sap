*&---------------------------------------------------------------------*
*& Report ZDEMO_SEL_LOOP_TABLE
*&---------------------------------------------------------------------*
*& DESCRIPTION: Selection Screen as Subscreen
*&---------------------------------------------------------------------*
REPORT zdemo_sel_screen_as_subscreen.

*PARAMETERS A AS CHECKBOX.

SELECTION-SCREEN BEGIN OF SCREEN 1100 AS SUBSCREEN NESTING LEVEL 4.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-010.
PARAMETERS: p1(10) TYPE c,
            p2(10) TYPE c,
            p3(10) TYPE c.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN END OF SCREEN 1100.

SELECTION-SCREEN BEGIN OF SCREEN 1200 AS SUBSCREEN NESTING LEVEL 4.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-020.
PARAMETERS: q1(10) TYPE c OBLIGATORY,
            q2(10) TYPE c OBLIGATORY,
            q3(10) TYPE c OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF SCREEN 1200.

DATA: ok_code TYPE sy-ucomm,
      save_ok TYPE sy-ucomm.

DATA: number(4) TYPE n VALUE '1100'.


START-OF-SELECTION.
  CALL SCREEN 100.


MODULE status_0100 OUTPUT.
  SET PF-STATUS 'SCREEN_100'.
ENDMODULE.

MODULE cancel INPUT.
  LEAVE PROGRAM.
ENDMODULE.

MODULE user_command_0100 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'BUTTON1'.
      number = 1100.
    WHEN 'BUTTON2'.
      number = 1200.
  ENDCASE.
ENDMODULE.

AT SELECTION-SCREEN.
  MESSAGE s888(sabapdemos) WITH text-030 sy-dynnr.
