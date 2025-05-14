# Duck Hunt
<img src="https://github.com/user-attachments/assets/7abffee2-576f-4241-9787-be799702e7b7" width="800" />

## Project Overview
<img src="https://github.com/user-attachments/assets/21375510-a9f8-4db0-9e80-dba3df2c94c5" width="500" />

The goal of this project was to create the iconic Duck Hunt game using the Nexys A7 board and a VGA monitor. The player navigates a reticle ball on the screen using the BTNU, BTNR, BTND, and BTNL buttons for horizontal and vertical movement. One ball, which is our duck, moves around the screen. When the player moves the reticle over the duck and presses the BTNC button, the duck is shot and the player gets a point. The points are shown on the right LED display. After about 10 seconds, the duck will respawn with faster movement. The player has 3 shots per duck, with the shot count displayed on the left LED display. If the player misses all 3 shots, the game is over. The duck and the reticle will both disappear. However, the player can hit the C12 button to restart the game.

## Necessary Attachments
In order to play the game, you will need:
- Nexys A7 Board
<img src="https://github.com/user-attachments/assets/8979fb36-ba38-44a6-9613-283e15bbc157" width="500" />

- VGA Cable
<img src="https://github.com/user-attachments/assets/6eee019c-604e-4399-8062-944f078882f7" width="500" />

- Monitor with VGA port or port that can utilize a VGA adapter
<img src="https://github.com/user-attachments/assets/a825ff81-97b6-4ad4-9dc6-1e04f05af86f" width="500" />

- Micro USB cable
<img src="https://github.com/user-attachments/assets/da1721a4-3f5c-4a0f-975d-794672c0838c" width="500" />
  
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

We got the framework of our project from Lab 6, the PONG project. Some functionality remained unchanged, like the motion of each ball, which we are now calling ducks, and the horizontal motion of the reticle. vga_sync.vhd, clk_wiz_0.vhd and clk_wiz_0_clk_wiz.vhd remained completely unchanged, with some minor modifications being made to leddec16.vhd, and major modifications to duckhunt.vhd (formerly pong.vhd), reticle.vhd (formerly bat_n_ball.vhd), and the new duck.vhd files.

### duckhunt.vhd changes
Vertical Movement
```
pos : PROCESS (clk_in) is
    BEGIN
        if rising_edge(clk_in) then
            count <= count + 1;
            IF (btnl = '1' and count = 0 and batpos_x > 0) THEN
                batpos_x <= batpos_x - 10;
            ELSIF (btnr = '1' and count = 0 and batpos_x < 800) THEN
                batpos_x <= batpos_x + 10;
            END IF;
            
            IF (btnu = '1' and count = 0 and batpos_y > 10) then
                batpos_y <= batpos_y - 10;
            ELSIF (btnd = '1' and count = 0 and batpos_y < 600) then
                batpos_y <= batpos_y + 10;
            END IF;
            
            
        end if;
    END PROCESS;
```

Here we took the existing code for moving the reticle right and left, and now added new conditions that allow us to move the reticle up and down with BTNU, and BTND.

leddec16 portmap
```
    PORT MAP(
      dig => led_mpx, data => "00"& miss& display, 
      anode => SEG7_anode, seg => SEG7_seg
    );
```
We needed to modify our port map as part of our project uses the first 4 digits of the 7 segment display to show the users score, and then the final digit to display how many shots the user has remaining. 
```
data => display 
```
was changed to
``` 
data => "00"& miss& display
``` 
This now passes the value of miss along with the rest of display, which is the user’s score.


### reticle.vhd changes
```
 ck_process: PROCESS(v_sync)
    BEGIN
        if rising_edge(v_sync) then
        SCORE <= localScore;
        game_state <= nx_game_state;
        MISS <= shot_count;
        END IF;
    END PROCESS;
```
Simple clocked process that is synchronized with v_sync to update the states of various states and outputs.
```

counter: PROCESS(clk)
    begin
        IF counterEnable = '1' then
            IF clk'EVENT and CLK = '1' then
                count <= count + 1;
            END IF;
        else
            count <= conv_std_logic_vector(0,32);
        END IF;
    END process;
```
Counter process, this is responsible for creating the delay between levels. 

```
gameManager: PROCESS(draw_on,counterFinished,v_sync)
    
    begin
    if rising_edge(v_sync) then
    nx_game_state <= game_state;
    
    IF game_state = ENABLE THEN
       IF draw_on = '0' then
       counterEnable <= '1';
        nx_game_state <= DISABLE;
       else
       counterEnable <= '0';
       respawn <= '0';
       END IF;
     ELSE --game_state = DISABLE
       IF counterFinished = '1' THEN
          counterEnable <= '0';
          nx_game_state <= ENABLE;
          respawn <= '1';
       ELSE
       counterEnable <= '1';
       END IF;
    END IF;
    END IF;
    
    
    IF shot_count = "00" THEN
        nx_game_state <= DISABLE;
        respawn <= '0';
    END IF;
    END PROCESS;
```
The gameManager process controls how the duck respawns for the next level, and also shuts down the game in the event of a game over.

```
   scoreupdate: PROCESS IS
        variable temp_score : unsigned(15 DOWNTO 0);
        variable hit_detected : STD_LOGIC;
    BEGIN
        wait until rising_edge(v_sync);
        if reset = '0' THEN
        shot_count <= "11";
        localScore <= conv_std_logic_vector(0,16);
        ELSE
        temp_score := unsigned(localScore);
        hit_detected := '0';
            IF HITS = '1' THEN
                IF HIT_FLAGS = '0' THEN
                temp_score := temp_score + 1;
                hit_detected := '1';
                shot_count <= "11";
                HIT_FLAGS <= '1';
                END IF;
            ELSE 
                HIT_FLAGS <= '0';
                END IF;
            localScore <= STD_LOGIC_VECTOR(temp_score);
            IF shoot = '1' and prev_shoot = '0' THEN
                IF HITS = '0' THEN
                    IF shot_count = "00" THEN
                    ELSE
                    shot_count <= shot_count - 1;
                    END IF;
                    END IF;
                END IF;
        prev_shoot <= shoot;
        END IF;
    END PROCESS;
```
This is the scoreUpdate process, this is where shoot inputs are tested to see if they were a hit or a miss and adjusts the game score or shot counter accordingly. It is also responsible for resetting the game when the reset button is pressed.

### leddec16.vhd changes
leddec16 architecture
```
ARCHITECTURE Behavioral OF leddec16 IS
	SIGNAL data4 : STD_LOGIC_VECTOR (3 DOWNTO 0); -- binary value of current digit
BEGIN
	-- Select digit data to be displayed in this mpx period
	data4 <= data(3 DOWNTO 0) WHEN dig = "000" ELSE -- digit 0
	         data(7 DOWNTO 4) WHEN dig = "001" ELSE -- digit 1
	         data(11 DOWNTO 8) WHEN dig = "010" ELSE -- digit 2
	         data(15 DOWNTO 12) WHEN dig ="011" ELSE-- digit 3
	         data(19 DOWNTO 16);
	-- Turn on segments corresponding to 4-bit data word
	seg <= "0000001" WHEN data4 = "0000" ELSE -- 0
	       "1001111" WHEN data4 = "0001" ELSE -- 1
	       "0010010" WHEN data4 = "0010" ELSE -- 2
	       "0000110" WHEN data4 = "0011" ELSE -- 3
	       "1001100" WHEN data4 = "0100" ELSE -- 4
	       "0100100" WHEN data4 = "0101" ELSE -- 5
	       "0100000" WHEN data4 = "0110" ELSE -- 6
	       "0001111" WHEN data4 = "0111" ELSE -- 7
	       "0000000" WHEN data4 = "1000" ELSE -- 8
	       "0000100" WHEN data4 = "1001" ELSE -- 9
	       "0001000" WHEN data4 = "1010" ELSE -- A
	       "1100000" WHEN data4 = "1011" ELSE -- B
	       "0110001" WHEN data4 = "1100" ELSE -- C
	       "1000010" WHEN data4 = "1101" ELSE -- D
	       "0110000" WHEN data4 = "1110" ELSE -- E
	       "0111000" WHEN data4 = "1111" ELSE -- F
	       "1111111";
	-- Turn on anode of 7-segment display addressed by 3-bit digit selector dig
	anode <= "11111110" WHEN dig = "000" ELSE -- 0
	         "11111101" WHEN dig = "001" ELSE -- 1
	         "11111011" WHEN dig = "010" ELSE -- 2
	         "11110111" WHEN dig = "011" ELSE -- 3
	      --   "11101111" WHEN dig = "100" ELSE -- 4
	      --   "11011111" WHEN dig = "101" ELSE -- 5
	      --"10111111" WHEN dig = "110" ELSE -- 6
	         "01111111" WHEN dig = "111" ELSE -- 7
	         "11111111";
END Behavioral;
```

Here inside the architecture for leddec16 we changed the data4 selection to allow for data(19 DOWNTO 6) when the dig is others, to allow us to display the shot counter on the last digit of the display. Additionally we needed to uncomment the line corresponding to the last digit in the annode select to enable the last digit of the display.

### duck.vhd changes

```
ck_process : process(v_sync)
    
    begin
    hit <= nx_hit;
    shot_state <= nx_shot_state;
    ball_speed <= nx_speed;
    end process;
```
Clock process to update signals to their next value based on the clock cycle

```
 hitDected : process
    
    BEGIN
    IF reset = '0' THEN
        game_on <= '1';
        nx_speed <= CONV_STD_LOGIC_VECTOR (2, 11);
        ELSE
        IF respawn = '1' THEN
        game_on <= '1';
        nx_hit <= '0';
        ELSE
        WAIT UNTIL rising_edge(v_sync);
        nx_speed <= ball_speed;
        nx_shot_state <= shot_state;
        IF shot_state = NOT_PRESSED THEN
            IF shoot = '1' THEN
                IF (ball_x + bsize/2) >= (bat_x - bat_w) AND
                (ball_x - bsize/2) <= (bat_x + bat_w) AND
                (ball_y + bsize/2) >= (bat_y - bat_h) AND
                (ball_y - bsize/2) <= (bat_y + bat_h) THEN
                    game_on <= '0';
                    nx_hit <= '1';
                    nx_speed <= ball_speed + 1;
                    END IF;
                nx_shot_state <= PRESSED;
            END IF;
        else
            IF shoot = '0' THEN
                nx_shot_state <= NOT_PRESSED;
            ELSE
                nx_shot_state <= PRESSED;
                END IF;
        END IF;
        END IF;
        END IF;
    END PROCESS;
```
Hit detection process, it first checks if the game is being reset or if the ball is being respawned, if it isnt then it checks of the ball is inside of the reticle when the shoot button is pressed. If it is a hit is registered.

## Conclusion
Thomas was responsible for debugging parts of the code (miss detection) and most of the README file. Jimmy was responsible for coding most of the project and parts of the README.

<ins>Timeline</ins>
- 4/22 - 4/24: Brainstormed ideas, began editing Lab 6 code with basic modifications (vertical movement buttons)
- 4/29 - 5/01: Began more complex modifications of Lab 6 code (two balls on screen, ball respawning)
- 5/06 - 5/12: Finished modifications and debugging (scoreboard, shot counter), updated github repository

We encountered difficulties with the hit tracking and getting the score to work. The main issue we had with the hit tracking was that the tracker would not implement the number of hits properly (i.e. one hit would count as two). The hit tracker also had issues with correctly identifying a miss. To solve these issues, we used a state machine to identify when the shoot button was pressed to keep the hit detection window open for a clock cycle. The scoreboard had issues with properly adding the hits when they were performed due to improperly implementing when the score would update. We originally attempted to have two balls at once, but this caused issues with changing the score values when two hits and score updates happened at once. To resolve this problem, we chose to only implement one ball. With the one ball, we converted the score into an unsigned and then updated it. After that, we converted it back into a std_logic_vector so that it could be displayed on the board.



