# Duck Hunt

## Project Overview
The goal of this project was to create the iconic Duck Hunt game using the Nexys A7 board and a VGA monitor. The player navigates a reticle ball on the screen using the BTNU, BTNR, BTND, and BTNL buttons for horizontal and vertical movement. One or two duck balls move around the screen depending on which mode the player chooses. The player can decide whihc mode to play by flipping the _ switch for one duck or the _ switch for two ducks. When the player moves the reticle over the duck and presses the BTNC button, the duck is shot and the players get points. After a few seconds, the duck will respawn with faster movement.

## Necessary Attachments
In order to play the game, you will need:
- Nexys A7 Board
  
- VGA Cable
  
- Monitor with VGA port or port that can utilize a VGA adapter
  
- Micro USB cable
  
- Computer with Vivado installed

## Block Diagram
Diagram

## Setup Requirements
First download the following files: 
- `clk_wiz_0.vhd`
- `clk_wiz_0_clk_wiz.vhd`
- `duck.vhd`
- `duckhunt.vhd`
- `duckhunt.xdc`
- `leddec16.vhd`
- `reticle.vhd`
- `vga_sync.vhd`

Then perform the following steps:
1. Connect the micro USB cable to your computer and the USB port on Nexys A7 board
2. Connect the VGA cable to the monitor and the VGA port on the Nexys A7 board
3. Create a new RTL project on Vivado
4. Add the downloaded `.vhd` files as source files to the project
5. Add the downloaded `.xdc` file as a constraint file to the project
6. Select the Nexys A7 board in the "Boards" section
7. Run the synthesis
8. Run the implementation
9. Generate the bitstream
10. Open the hardware manager, then click "Open Target" and "Autoconnect"
11. Click "Program Device" and select xc7a100t_0 (the Nexys A7)

After following these steps, the program should run on the VGA monitor.

## Inputs and Outputs
The inputs and outputs of the game are as follows:

### duck.vhd
```
entity duck is
    Port (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position
        bat_y : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        shoot : IN STD_LOGIC;
        x_position : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
        y_position : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
        draw_on : OUT STD_LOGIC;
        X_DIR : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        hit : OUT STD_LOGIC
     );
end duck;
```
**Inputs:**
- v_sync: Synches with the VGA monitor
- pixel_row: The position of the row
- pixel_column: The position of the column
- bat_x: The current x-position of the reticle
- bat_y: The current y-position of the reticle
- shoot: The input from pressing the BTNC (shoot) button
- X_DIR: The initial x-position used to avoid the ducks spawning on top of one another

**Outputs:**
- x-position: The current x-position of the duck
- y-position: The current y-position of the duck
- draw_on: Checks if duck should be on screen
- hit: Registers if duck has been hit or not

### duckhunt.vhd
```
ENTITY duckhunt IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA outputs
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        btnl : IN STD_LOGIC;
        btnr : IN STD_LOGIC;
        btn0 : IN STD_LOGIC;
        btnu : IN STD_LOGIC;
        btnd : in STD_LOGIC;
        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of four 7-seg displays
        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    ); 
END duckhunt;
```
**Inputs:**
- clk_in: The system clock
- btnl: The input from pressing the BTNL button, moves the reticle leftwards horizontally
- btnr: The input from pressing the BTNR button, moves the reticle rightwards horizontally
- btn0: The input from pressing the BTNC button, shoots the duck if the reticle if the reticle is on the duck
- btnu: The input from pressing the BTNU button, moves the reticle upwards vertically
- btnd: The input from pressing the BTND button, moves the reticle downwards vertically

**Outputs:**
- VGA_red: The signal used for managing the red color displays for the VGA monitor
- VGA_green: The signal used for managing the green color displays for the VGA monitor
- VGA_blue: The signal used for managing the blue color displays for the VGA monitor
- VGA_hsync: The horizontal sync signal for the VGA monitor
- VGA_vsync: The vertical sync signal for the VGA monitor
- SEG7_anode: Controls which of section of the LED display turns on 
- SEG7_seg: Controls what number the LED display shows

### leddec16.vhd
```
ENTITY leddec16 IS
	PORT (
		dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0); -- which digit to currently display
		data : IN STD_LOGIC_VECTOR (15 DOWNTO 0); -- 16-bit (4-digit) data
		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- which anode to turn on
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)); -- segment code for current digit
END leddec16;
```
**Inputs:**
- dig: Controls what digit the LED displays
- data: The 16-bit or 4-digit data

**Outputs:**
- anode: Controls which anode to turn on
- seg: Segment code for the current digit

### reticle.vhd
```
ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position
        bat_y : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        serve : IN STD_LOGIC; -- initiates serve
        shoot : IN STD_LOGIC;
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        SCORE : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
END bat_n_ball;
```
**Inputs:**
- serve: Spawns in ducks

**Outputs:**
- red: The red color signal for the VGA monitor to display
- green: The green color signal for the VGA monitor to display
- blue: The blue color signal for the VGA monitor to display
- SCORE: The signal for keeping track of the player's score

### vga_sync.vhd
```
ENTITY vga_sync IS
	PORT (
		pixel_clk : IN STD_LOGIC;
		red_in    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		green_in  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		blue_in   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		red_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		green_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		blue_out  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		hsync     : OUT STD_LOGIC;
		vsync     : OUT STD_LOGIC;
		pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
		pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
	);
END vga_sync;
```
**Inputs:**
- pixel_clk:
- red_in: The input for the red color channel
- green_in: The input for the green color channel
- blue_in: The input for the blue color channel

**Outputs:**
- red_out: The output for the red color
- green_out: The output for the green color
- blue_out: The output for the blue color
- hsync: The horizontal sync signal
- vsync: The vertical sync signal

## Modifications
We began by modifying the pong code from Lab 6.

## Conclusion
