LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


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

ARCHITECTURE Behavioral OF reticle IS
    

    type stage is (ENABLE, DISABLE);
    CONSTANT bsize : INTEGER := 8; -- ball size in pixels
    CONSTANT bat_w : INTEGER := 20; -- bat width in pixels
    CONSTANT bat_h : INTEGER := 20; -- bat height in pixels
    CONSTANT bat_size : INTEGER := 20;
    -- distance ball moves each frame
    --CONSTANT ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (2, 11);
    SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position


    SIGNAL duck_x : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL duck_y : STD_LOGIC_VECTOR(10 DOWNTO 0);
    -- bat vertical position
    --CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    --SIGNAL ball_x_motion, ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    SIGNAL draw_on : STD_LOGIC;
    SIGNAL HITS : STD_LOGIC := '0';
    SIGNAL HIT_FLAGS : STD_LOGIC:= '0';
    SIGNAL localScore : STD_LOGIC_VECTOR (15 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (0, 16);
    
    SIGNAL game_state, nx_game_state : stage;
    SIGNAL counterEnable,counterFinished: STD_LOGIC;
    SIGNAL count : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL respawn : STD_LOGIC;
    
    SIGNAL shot_count : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
    SIGNAL prev_shoot : STD_LOGIC := '0';
    
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
        HIT : OUT STD_LOGIC;
        respawn : IN STD_LOGIC;
        reset : IN STD_LOGIC
        );
        end component;
    
BEGIN
    red <= NOT bat_on; -- color setup for red ball and cyan bat on white background
    green <= NOT ball_on;
    blue <= NOT ball_on;
    counterFinished <= count(30);
    -- process to draw round ball
    -- set ball_on if current pixel address is covered by ball position
    duck_1 : duck PORT MAP(
        v_sync => v_sync, 
        pixel_row => pixel_row, 
        pixel_col => pixel_col, 
        bat_x => bat_x, 
        bat_y => bat_y ,
        shoot => shoot,
        x_position => duck_x, 
        y_position => duck_y, 
        draw_on => draw_on,
        X_DIR => CONV_STD_LOGIC_VECTOR(400, 11),
        HIT => HITS,
        respawn => respawn,
        reset => reset
    );

    ck_process: PROCESS(v_sync)
    BEGIN
        if rising_edge(v_sync) then
        SCORE <= localScore;
        game_state <= nx_game_state;
        MISS <= shot_count;
        END IF;
    END PROCESS;
    
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
    
    
    balldraw : PROCESS (duck_x, duck_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
        VARIABLE draw : STD_LOGIC;
    BEGIN
        IF shot_count = "00" THEN
        ELSE
        IF pixel_col <= duck_x THEN -- vx = |ball_x - pixel_col|
            vx := duck_x - pixel_col;
        ELSE
            vx := pixel_col - duck_x;
        END IF;
        IF pixel_row <= duck_y THEN -- vy = |ball_y - pixel_row|
            vy := duck_y - pixel_row;
        ELSE
            vy := pixel_row - duck_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            draw := draw_on;
        ELSE
            draw := '0';
        END IF;
        END IF;
        ball_on <= draw;
    END PROCESS;

    -- process to draw bat
    -- set bat_on if current pixel address is covered by bat position
    batdraw : PROCESS (bat_x, bat_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
    IF shot_count = "00" then
    ELSE
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
        END IF;
    END PROCESS;
    -- process to move ball once every frame (i.e., once every vsync pulse)
    
END Behavioral;