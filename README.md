# ChatAlert
Makes a sound when key terms are found in chat

If only primary terms are defined; ChatAlert will only look for those terms and alert you if any primary term is found in game chat.  <br>
If secondary terms are defined; ChatAlert will only alert you if a term from both primary and secondary lists is found.  <br>
If an ignored term is defined; If an ignored term is found in the message, ChatAlert will NOT alert you. Even if primary and secondary terms are present.

## Example 1: 
Primary terms: "wts", "Polearm", "Do you need it?"  <br>
Secondary terms: empty

incoming yell>> WTS Brone Sword {/tell}  <br>
  Since secondary list is empty then ChatAlert will alert you that "wts" was found in the message.

## Example 2:
Primary terms: "wts", "Do you need it?"  <br>
Secondary terms: "Polearm"

incoming yell>> WTS Bronze Sword {/tell}  <br>
  Primary term, "wts", was in the message but ChatAlert will NOT alert you because no secondary term was found in the message.

incoming yell>> WTS my favorite Polearm PM me  <br>
  ChatAlert will alert you because primary term, "wts", and secondart term, "polearm" were both found in the message

```
/ca add1 <term> - add a primary term. (not case sensative, can include spaces)
/ca add2 <term> - add a secondary term. (not case sensative, can include spaces)
/ca ignore <term> - add a term to be ignored. (not case sensative, can include spaces)
/ca list - list all terms.
/ca clear all - clear all terms.
/ca clear primary - clear primary terms.
/ca clear secondary - clear secondary terms.
/ca clear ignored - clear ignored terms.
/ca msg - toggle addon messages.
/ca alert <1-7> - change the alert sound.
/ca help - print help.
```
