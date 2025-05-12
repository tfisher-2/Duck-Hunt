LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

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

ARCHITECTURE Behavioral OF bat_n_ball IS
    
    type position_array is array (0 to 1) of STD_LOGIC_VECTOR(10 DOWNTO 0);
    CONSTANT bsize : INTEGER := 8; -- ball size in pixels
    CONSTANT bat_w : INTEGER := 20; -- bat width in pixels
    CONSTANT bat_h : INTEGER := 20; -- bat height in pixels
    CONSTANT bat_size : INTEGER := 20;
    -- distance ball moves each frame
    --CONSTANT ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (2, 11);
    SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
   -- SIGNAL game_on : STD_LOGIC := '1'; -- indicates whether ball is in play
    -- current ball position - intitialized to center of screen
    SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL ball_x_1 : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL ball_y_1 : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL duck_x : position_array;
    SIGNAL duck_y : position_array;
    -- bat vertical position
    --CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    --SIGNAL ball_x_motion, ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    SIGNAL draw_on : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL HITS : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL HIT_FLAGS : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL localScore : STD_LOGIC_VECTOR (15 DOWNTO 0) := CONV_STD_LOGIC_VECTOR ( 0, 16);
    
    component duck is
        port(
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position
        bat_y : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        shoot : IN STD_LOGIC;
        x_position : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
        y_position : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
        draw_on : OUT STD_LOGIC;
        X_DIR : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        HIT : OUT STD_LOGIC
        );
        end component;
    
BEGIN
    red <= NOT bat_on; -- color setup for red ball and cyan bat on white background
    green <= NOT ball_on;
    blue <= NOT ball_on;
    -- process to draw round ball
    -- set ball_on if current pixel address is covered by ball position
    duck_1 : duck PORT MAP(
         v_sync => v_sync, 
        pixel_row => pixel_row, 
        pixel_col => pixel_col, 
        bat_x => bat_x, 
        bat_y => bat_y ,
        shoot => shoot,
        x_position => duck_x(0), 
        y_position => duck_y(0), 
        draw_on => draw_on(0),
        X_DIR => CONV_STD_LOGIC_VECTOR(400, 11),
        HIT => HITS(0)
    );
    duck_2 : duck PORT MAP(
        v_sync => v_sync, 
        pixel_row => pixel_row, 
        pixel_col => pixel_col, 
        bat_x => bat_x, 
        bat_y => bat_y ,
        shoot => shoot,
        x_position => duck_x(1), 
        y_position => duck_y(1), 
        draw_on => draw_on(1),
        X_DIR => CONV_STD_LOGIC_VECTOR(0, 11),
        HIT => HITS(1)
    );
    
    scoreupdate: PROCESS(HITS) IS
    BEGIN
            IF HITS(0) <= '1' THEN
                IF HIT_FLAGS(0) = '0' THEN
                localScore <= localScore + 1;
                HIT_FLAGS(0) <= '1';
                END IF;
            ELSE 
                HIT_FLAGS(0) <= '0';
                END IF;
            IF HITS(1) <= '1' THEN
                IF HIT_FLAGS(1) = '0' THEN
                localScore <= localScore + 1;
                HIT_FLAGS(1) <= '1';
                END IF;
            ELSE 
                HIT_FLAGS(1) <= '0';
                END IF;
    END PROCESS;
    
    balldraw : PROCESS (duck_x, duck_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
        VARIABLE draw : STD_LOGIC_VECTOR(1 DOWNTO 0);
    BEGIN
        SCORE <= localScore;
        for i in 0 to 1 loop
        IF pixel_col <= duck_x(i) THEN -- vx = |ball_x - pixel_col|
            vx := duck_x(i) - pixel_col;
        ELSE
            vx := pixel_col - duck_x(i);
        END IF;
        IF pixel_row <= duck_y(i) THEN -- vy = |ball_y - pixel_row|
            vy := duck_y(i) - pixel_row;
        ELSE
            vy := pixel_row - duck_y(i);
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            draw(i) := draw_on(i);
        ELSE
            draw(i) := '0';
        END IF;
        end loop;
        ball_on <= draw(0) or draw(1);
    END PROCESS;

    -- process to draw bat
    -- set bat_on if current pixel address is covered by bat position
    batdraw : PROCESS (bat_x, bat_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
      --  IF ((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
      --   pixel_col <= bat_x + bat_w AND
      --       pixel_row >= bat_y - bat_h AND
      --       pixel_row <= bat_y + bat_h THEN
      --          bat_on <= '1';
        IF pixel_col <= bat_x THEN
            vx := bat_x - pixel_col;
        ELSE 
            vx := pixel_col - bat_x;
        END IF;
        IF pixel_row <= bat_y THEN
            vy := bat_y - pixel_row;
        ELSE
            vy := pixel_row - bat_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bat_size * bat_size) then
            bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;
    END PROCESS;
    -- process to move ball once every frame (i.e., once every vsync pulse)
    
END Behavioral;
