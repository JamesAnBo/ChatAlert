# ChatAlert
Makes a sound when key terms are found in chat

If only primary terms are defined, ChatAlert will only look for those terms and alert you if any primary term is found in game chat.
If secondary terms are defined, ChatAlert will only alert you if a term from both primary and secondary lists is found.

Example 1:
Primary terms: "wts", "Polearm", "Do you need it?"
Secondary terms: empty

incoming yell>> WTS Brone Sword {/tell}
  Since secondary list is empty then ChatAlert will alert you that "wts" was found in the message.

Example 2:
Primary terms: "wts", "Do you need it?"
Secondary terms: "Polearm"

incoming yell>> WTS Bronze Sword {/tell}
  Primary term, "wts", was in the message but ChatAlert will NOT alert you because no secondary term was found in the message.

incoming yell>> WTS my favorite Polearm PM me
  ChatAlert will alert you because primary term, "wts", and secondart term, "polearm" were both found in the message

```
/ca add1 <term> - add a primary term. (not case sensative, can include spaces)
/ca add2 <term> - add a secondary term. (not case sensative, can include spaces)
/ca list - list all terms.
/ca clear all - clear all terms.
/ca clear primary - clear primary terms.
/ca clear secondary - clear secondary terms.
/ca help - print help.
```
