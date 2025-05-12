# Duck Hunt

## Project Overview
The goal of this project was to create the iconic Duck Hunt game using the Nexys A7 board and a VGA monitor. The player navigates a reticle ball on the screen using the BTNU, BTNR, BTND, and BTNL buttons for horizontal and vertical movement. One ball, which is our duck, moves around the screen. When the player moves the reticle over the duck and presses the BTNC button, the duck is shot and the player gets a point. The points are shown on the right LED display. After about 10 seconds, the duck will respawn with faster movement. The player has 3 shots per duck, with the shot count displayed on the left LED display. If the player misses all 3 shots, the game is over. The duck and the reticle will both disappear. However, the player can hit the C12 button to restart the game.

## Necessary Attachments
In order to play the game, you will need:
- Nexys A7 Board
  
- VGA Cable
  
- Monitor with VGA port or port that can utilize a VGA adapter
  
- Micro USB cable
  
- Computer with Vivado installed

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
        hit : OUT STD_LOGIC;
        respawn: IN STD_LOGIC;
        reset: IN STD_LOGIC
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
- respawn: Respawns the next duck
- reset: Resets the game

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
        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        reset : in STD_LOGIC
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
- reset: Resets the game

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
		data : IN STD_LOGIC_VECTOR (19 DOWNTO 0); -- 19-bit (4-digit) data
		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- which anode to turn on
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)); -- segment code for current digit
END leddec16;
```
**Inputs:**
- dig: Controls what digit the LED displays
- data: The 19-bit or 4-digit data

**Outputs:**
- anode: Controls which anode to turn on
- seg: Segment code for the current digit

### reticle.vhd
```
ENTITY reticle IS
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
        SCORE : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        clk : IN STD_LOGIC;
        MISS : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        reset : IN STD_LOGIC
    );
END reticle;

```
**Inputs:**
- serve: Spawns in ducks
- shoot: Registers if the duck has been shot

**Outputs:**
- red: The red color signal for the VGA monitor to display
- green: The green color signal for the VGA monitor to display
- blue: The blue color signal for the VGA monitor to display
- SCORE: The signal for keeping track of the player's score
-MISS: Registers if a shot has been missed

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
Thomas was responsible for debugging parts of the code (miss detection) and most of the README file. Jimmy was responsible for coding most of the project and parts of the README.

<ins>Timeline</ins>
- 4/22 - 4/24: Brainstormed ideas, began editing Lab 6 code with basic modifications (vertical movement buttons)
- 4/29 - 5/01: Began more complex modifications of Lab 6 code (two balls on screen, ball respawning)
- 5/06 - 5/12: Finished modifications and debugging (scoreboard, shot counter), updated github repository

We encountered difficulties with the hit tracking and getting the score to work. The main issue we had with the hit tracking was that the tracker would not implement the number of hits properly (i.e. one hit would count as two). The hit tracker also had issues with correctly identifying a miss. To solve these issues, we used a state machine to identify when the shoot button was pressed to keep the hit detection window open for a clock cycle. The scoreboard had issues with properly adding the hits when they were performed due to improperly implementing when the score would update. We originally attempted to have two balls at once, but this caused issues with changing the score values when two hits and score updates happened at once. To resolve this problem, we chose to only implement one ball. With the one ball, we converted the score into an unsigned and then updated it. After that, we converted it back into a std_logic_vector so that it could be displayed on the board.
