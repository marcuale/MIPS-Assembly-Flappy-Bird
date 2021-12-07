# MIPS-Assembly-Flappy-Bird

Recreated popular mobile game 'Flappy Bird' in MIPS Assembly Language.

The game implements:

  - Dynamic pipe height, with multiple obstacles shown on screen
  - Two birds. (Please note: 'f' moves the bird on the left (which is the main bird). 'j' moves the bird on the right. If the bird on the right 'dies', you can continue playing                     with f. But, tapping both 'f' and 'j' at the same time crashes MARS (not just our program) so careful!
  - Background colour fades from day to night and cycles as the game progresses


Bitmap Display Configuration:
 - Unit width in pixels: 8					     
 - Unit height in pixels: 8
 - Display width in pixels: 256
 - Display height in pixels: 256
 - Base Address for Display: 0x10008000 ($gp)
  
