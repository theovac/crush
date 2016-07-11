# crush_repo
  A VHDL implementation of a Candy Crush like game using FPGA.

  ----- Project Structure ------

- Frame Buffer
The game uses a framebuffer which splits the screen in 40x40px blocks. We used 640x480px resolution so the framebuffer is a 12x16 array
that hold a 3 bit sprite id in each for each block. The frame buffer alson handles the game logic in a try to avoid multiple clock cycle 
delays during r/w operations.

- Sprite ROM
We used a ROM to store the bit arrays for each sprite. The ROM and the framebuffer can calculate the pixel row and column using the horizontal and vertical 
counters from the VGA protocol. The frame buffer outputs the sprite id for each block and the ROM returns a 40 bit row of pixels.

- VGA controller
The VGA controller implements the VGA protocol and also draws the game using the data (40 pixel row) provided by the ROM.

- Other controllers 
We also implemented three controllers for player movenent (movement.vhd) block swapping (swap.vhd) and ps\2 keyboard input (ps2_keyboard.vhd).
