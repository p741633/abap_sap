# Basic Syntax

## Statements

- บรรทัดแรกของโปรแกรมจะขึ้นต้นด้วยคำว่า REPORT ตามด้วยชื่อโปรแกรมที่เราสร้างไว้จาก SE38
- จบบรรทัดด้วย Full stop (.)

```abap
REPORT [Program_Name].

[Statements…].
```

## Colon Notation

- สามารถเชื่อมคำสั่งเข้าด้วยกันได้ด้วย Colon (:) และ Commas (,)

```abap
WRITE 'Hello'.
WRITE 'ABAP'.
WRITE 'World'.
```

- ใช้ colon และ commas ในการเชื่อมคำสั่ง

```abap
WRITE: 'Hello',
       'ABAP',
       'World'.
```

- คำสั่ง ABAP Layout ไม่มีผลกับโค้ด

```abap
WRITE: 'Hello', 'ABAP', 'World'.
```

## Comments

- Comment ทั้งบรรทัด ใช้ Asterisk (\*) ตำแหน่งแรกของบรรทัด

```abap
* This is the comment line
```

- Comment ใน code ใช้ Quote (") ตำแหน่งท้ายสุดของบรรทัด

```abap
WRITE 'Hello'. "Here is the partial comment
```

## Suppressing Blanks

- คำสั่ง NO-ZERO เป็นการตัด 0 ที่อยู่ข้างหน้าตัวเลข

```abap
REPORT Z_Test123_01.

DATA: W_NUR(10) TYPE N.
      MOVE 50 TO W_NUR.
      WRITE W_NUR NO-ZERO.
```

- จาก code ด้านบน output คือ

```abap
50
```

- ถ้าไม่ใช้คำสั่ง NO-ZERO output จะเป็น 0000000050

## Blank Lines

- เพิ่มบรรทัดใหม่ด้วยคำสั่ง SKIP

```abap
WRITE 'This is the 1st line'.
SKIP.
WRITE 'This is the 2nd line'.
```

- จาก code ด้านบน output คือ

```abap
This is the 1st line
This is the 2nd line
```

- เราสามารถใส่จำนวนที่ต้องการเพิ่มบรรทัดใหม่ได้

```abap
SKIP number_of_lines.
```

- คำสั่ง SKIP สามารถใช้ในการเลื่อน cursor ไปตามบรรทัดของ page ได้

```abap
SKIP TO LINE line_number.
```

## Inserting Lines

- คำสั่ง ULINE สำหรับใส่เส้นตรง (เส้นคั่นบรรทัด)

```abap
WRITE 'This is Underlined'.
ULINE.
```

## Messages

- คำสั่ง MESSAGE สำหรับแสดงข้อความโดยการกำหนด message ID ในส่วน REPORT ด้านบนสุดของโปรแกรม
- message ID ประกอบไปด้วย 2 character code
- รหัสตัวเลข 000 to 999 สำหรับหมายเลขที่จะแสดงข้อความ
- ตัวอักษร แสดงประเภทของ message

| Message | Type        |
| ------- | ----------- |
| E       | Error       |
| W       | Warning     |
| I       | Information |
| A       | Abend       |
| S       | Success     |
| X       | Abort       |

- ประเภท message = E, message ID = AB, รหัสตัวเลข 011

```abap
EAB011 This report does not support sub-number summarization.
```
