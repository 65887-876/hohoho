import pygame
import math
import random
import os
from enemy import Enemy
import button
from record_syst import RecordSystem
# import matplotlib.pyplot as plt

# initialise pygame
pygame.init()
rs = RecordSystem()
SCREEN_SCALE = 0.5

class Menu:
    def __init__(self, screen_width, screen_height):
        self.screen_width = screen_width
        self.screen_height = screen_height
        self.title = "Castle Defender"
        self.font = pygame.font.SysFont('Futura', int(60*(0.2+SCREEN_SCALE)))
        self.play_button_image = pygame.image.load("img/menu/play.png").convert_alpha()
        self.play_button_image = pygame.transform.scale(self.play_button_image, (self.play_button_image.get_width()*SCREEN_SCALE, self.play_button_image.get_height()*SCREEN_SCALE))
        self.bg = pygame.transform.scale(pygame.image.load('img/menu/bg.png').convert_alpha(), (screen_width, screen_height))
        self.play_button_rect = self.play_button_image.get_rect(center=(self.screen_width / 2, self.screen_height / 2))
        self.play_clicked = False

    def draw(self, screen):
        # Draw bg
        screen.blit(self.bg, (0, 0))
        # Draw title
        title = self.font.render(self.title, True, (255, 255, 255))
        title_rect = title.get_rect(center=(self.screen_width / 2, self.screen_height / 4))
        screen.blit(title, title_rect)

        # Draw bg button
        screen.blit(self.play_button_image, self.play_button_rect)

        # Draw play button
        screen.blit(self.play_button_image, self.play_button_rect)


class Castle():

    def __init__(self, image100, image50, image25, x, y, scale):
        self.health = 1000
        self.max_health = self.health
        self.fired = False
        self.money = 0
        self.score = 0
        self.shots_fired = 0
        width = image100.get_width()
        height = image100.get_height()

        self.image100 = pygame.transform.scale(image100, (int(width * 0.45*SCREEN_SCALE), int(height * 0.45*SCREEN_SCALE)))
        self.image50 = pygame.transform.scale(image50, (int(width * 0.45*SCREEN_SCALE), int(height * 0.45*SCREEN_SCALE)))
        self.image25 = pygame.transform.scale(image25, (int(width * 0.45*SCREEN_SCALE), int(height * 0.45*SCREEN_SCALE)))
        self.rect = self.image100.get_rect()
        self.rect.x = screen_width*0.79
        self.rect.y = screen_height*0.46

    def shoot(self):
        pos = pygame.mouse.get_pos()
        x_dist = pos[0] - self.rect.midleft[0]
        y_dist = -(pos[1] - self.rect.midleft[1])
        self.angle = math.degrees(math.atan2(y_dist, x_dist))
        # get mouseclick
        if pygame.mouse.get_pressed()[0] and self.fired == False and pos[1] > 70:
            self.fired = True
            bullet = Bullet(bullet_img, self.rect.midleft[0], self.rect.midleft[1], self.angle)
            bullet_group.add(bullet)
            self.shots_fired += 1
        # reset mouseclick
        if pygame.mouse.get_pressed()[0] == False:
            self.fired = False

    def draw(self):
        # check which image to use based on health
        if self.health <= 250:
            self.image = self.image25
            self.rect.x = screen_width-(self.image.get_width()*(SCREEN_SCALE+0.15))
            self.rect.y = screen_height-self.image.get_height()
        elif self.health <= 500:
            self.image = self.image50
            self.rect.x = screen_width-(self.image.get_width()*(SCREEN_SCALE+0.15))
            self.rect.y = screen_height-self.image.get_height()
        else:
            self.image = self.image100
            self.rect.x = screen_width-(self.image.get_width()*(SCREEN_SCALE+0.15))
            self.rect.y = screen_height-self.image.get_height()

        screen.blit(self.image, self.rect)

    def repair(self):
        if self.money >= 1000 and self.health < self.max_health:
            self.health += 500
            self.money -= 1000
            if castle.health > castle.max_health:
                castle.health = castle.max_health

    def armour(self):
        if self.money >= 500:
            self.max_health += 250
            self.money -= 500



class Tower(pygame.sprite.Sprite):
    """This class creates a Tower object in a Pygame application that inherits from the pygame.sprite.Sprite class.
    It takes in three images for the tower, one for 100% health, one for 50% health, and one for 25% health,
    x and y coordinates, and a scale. It updates the tower by rotating it towards the closest enemy, shooting bullets
    at it with a defined cooldown and changing the image of the tower depending on the health of the castle. """

    def __init__(self, image100, image50, image25, x, y, scale):
        pygame.sprite.Sprite.__init__(self)

        self.got_target = False
        self.angle = 0
        self.last_shot = pygame.time.get_ticks()

        width = image100.get_width()
        height = image100.get_height()
        self.castle_scale = SCREEN_SCALE/2
        self.castle100 = pygame.transform.scale(image100, (int(width * self.castle_scale), int(height * self.castle_scale)))
        self.castle50 = pygame.transform.scale(image50, (int(width * self.castle_scale), int(height * self.castle_scale)))
        self.castle25 = pygame.transform.scale(image25, (int(width * self.castle_scale), int(height * self.castle_scale)))
        self.image = self.castle100
        self.rect = self.castle100.get_rect()
        self.rect.x = x*SCREEN_SCALE
        self.rect.y = (y - 100)*SCREEN_SCALE

    def update(self, enemy_group):
        self.got_target = False

        for e in enemy_group:
            if e.alive:
                target_x, target_y = e.rect.midbottom
                self.got_target = True
                break

        if self.got_target:
            x_dist = target_x - self.rect.midleft[0]
            y_dist = -(target_y - self.rect.midleft[1])
            self.angle = math.degrees(math.atan2(y_dist, x_dist))

            shot_cooldown = 1000
            # fire bullet
            if pygame.time.get_ticks() - self.last_shot > shot_cooldown:
                self.last_shot = pygame.time.get_ticks()
                bullet = Bullet(bullet_img, self.rect.midleft[0], self.rect.midleft[1], self.angle)
                bullet_group.add(bullet)

        # check which image to use based on health
        if castle.health <= 250:
            self.image = self.castle25
        elif castle.health <= 500:
            self.image = self.castle50
        else:
            self.image = self.castle100


class Bullet(pygame.sprite.Sprite):
    """ This class creates a bullet object that inherits from the pygame.sprite.Sprite class in Pygame. It takes in
    an image, x and y coordinates, and an angle as arguments, calculates the horizontal and vertical speeds based on
    the angle, and updates the bullet's position and checks if the bullet has gone off the screen, if so it kills the
    bullet. """

    def __init__(self, image, x, y, angle):
        pygame.sprite.Sprite.__init__(self)
        self.image = image
        self.rect = self.image.get_rect()
        self.rect.x = x
        self.rect.y = y
        self.angle = math.radians(angle)  # convert input angle into radians
        self.speed = 10
        # calculate the horizontal and vertical speeds based on the angle
        self.dx = math.cos(self.angle) * self.speed
        self.dy = -(math.sin(self.angle) * self.speed)

    def update(self):
        # check if bullet has gone off the screen
        if self.rect.right < 0 or self.rect.left > screen_width or self.rect.bottom < 0 or self.rect.top > screen_height:
            self.kill()

        # move bullet
        self.rect.x += self.dx
        self.rect.y += self.dy


class Crosshair():
    """
    Sets the crosshair position to the centre of the cursor and removes the cursor from the screen
    """

    def __init__(self, scale):
        image = pygame.image.load('img/game/crosshair.png').convert_alpha()
        width = image.get_width()
        height = image.get_height()

        self.image = pygame.transform.scale(image, (int(width * scale), int(height * scale)))
        self.rect = self.image.get_rect()

        # hide mouse
        pygame.mouse.set_visible(False)

    def draw(self):
        mx, my = pygame.mouse.get_pos()
        self.rect.center = (mx, my)
        screen.blit(self.image, self.rect)


class Main():
    def __init__(self):
        pass

    """
    
    Need to take all the global variables and add it into this main class with the main game loop, loading high 
    score, animations show info all being there own methods. 
    
    """


# game window
screen_width = 1920 * SCREEN_SCALE
screen_height = 1080 * SCREEN_SCALE

# create game window
screen = pygame.display.set_mode((screen_width, screen_height))
pygame.display.set_caption('Castle Defender')

clock = pygame.time.Clock()
FPS = 60

# define game variables
level = 1
high_score = 0
level_difficulty = 0
target_difficulty = 1000
DIFFICULTY_MULTIPLIER = 2
game_over = False
next_level = False
ENEMY_TIMER = 1000
last_enemy = pygame.time.get_ticks()
enemies_alive = 0
max_towers = 4
tower_positions = [
    [screen_width - 250*SCREEN_SCALE, screen_height - 200*SCREEN_SCALE],
    [screen_width - 200*SCREEN_SCALE, screen_height - 150*SCREEN_SCALE],
    [screen_width - 150*SCREEN_SCALE, screen_height - 150*SCREEN_SCALE],
    [screen_width - 100*SCREEN_SCALE, screen_height - 150*SCREEN_SCALE],
]
TOWER_COST = 10



# define colours
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)

# define font
font = pygame.font.SysFont('Futura', int(40*(0.2+SCREEN_SCALE)))
font_60 = pygame.font.SysFont('Futura', int(60*(0.2+SCREEN_SCALE)))

# load images
map = pygame.transform.scale(pygame.image.load('img/menu/bg.png').convert_alpha(), (screen_width, screen_height))

# castle images
castle_img_100 = pygame.image.load('img/castle/castle_100.png').convert_alpha()
castle_img_50 = pygame.image.load('img/castle/castle_50.png').convert_alpha()
castle_img_25 = pygame.image.load('img/castle/castle_25.png').convert_alpha()

# tower images
tower_img_100 = pygame.image.load('img/tower/tower_100.png').convert_alpha()
tower_img_50 = pygame.image.load('img/tower/tower_50.png').convert_alpha()
tower_img_25 = pygame.image.load('img/tower/tower_25.png').convert_alpha()

# bullet image
bullet_img = pygame.image.load('img/game/bullet.png').convert_alpha()
b_w = bullet_img.get_width()
b_h = bullet_img.get_height()
bullet_img = pygame.transform.scale(bullet_img, (int(b_w * SCREEN_SCALE/2), int(b_h * SCREEN_SCALE/2)))

# load enemies
enemy_animations = []
enemy_types = ['knight', 'goblin', 'purple_goblin', 'red_goblin']
enemy_health = [75, 100, 125, 150]

animation_types = ['walk', 'attack', 'death']
for enemy in enemy_types:
    # load animation
    animation_list = []
    for animation in animation_types:
        # reset temporary list of images
        temp_list = []
        # define number of frames
        num_of_frames = 20
        for i in range(num_of_frames):
            img = pygame.image.load(f'img/enemies/{enemy}/{animation}/{i}.png').convert_alpha()
            e_w = img.get_width()
            e_h = img.get_height()
            img = pygame.transform.scale(img, (int(e_w * 0.5*SCREEN_SCALE), int(e_h * 0.5*SCREEN_SCALE)))
            temp_list.append(img)
        animation_list.append(temp_list)
    enemy_animations.append(animation_list)

# repair image
repair_img = pygame.image.load('img/game/repair.png').convert_alpha()
# armour image
armour_img = pygame.image.load('img/game/armour.png').convert_alpha()
tabel_img = pygame.transform.scale(pygame.image.load('Assets/Leaderboard/table.png').convert_alpha(), (screen_width, screen_height))
scores_btn_img = pygame.image.load('Assets/Leaderboard/button_menu.png').convert_alpha()
play_btn_img = pygame.image.load("img/menu/play.png").convert_alpha()

# function for outputting text onto the screen
def draw_text(text, font, text_col, x, y):
    img = font.render(text, True, text_col)
    screen.blit(img, (x, y))


# function for displaying status
def show_info():
    draw_text('Money: ' + str(castle.money), font, BLACK, 20*SCREEN_SCALE, 10*SCREEN_SCALE)
    draw_text('Score: ' + str(castle.score), font, BLACK, 300*SCREEN_SCALE, 10*SCREEN_SCALE)
    draw_text('High Score: ' + str(high_score), font, BLACK, 200*SCREEN_SCALE, 40*SCREEN_SCALE)
    draw_text('Level: ' + str(level), font, BLACK, screen_width*SCREEN_SCALE // 2+70, 10*SCREEN_SCALE)
    draw_text('Health: ' + str(castle.health) + " / " + str(castle.max_health), font, BLACK, screen_width - 400*SCREEN_SCALE,
              screen_height - 600*SCREEN_SCALE)
    draw_text('1000', font, BLACK, screen_width - 220*SCREEN_SCALE, 70*SCREEN_SCALE)
    draw_text(str(TOWER_COST), font, BLACK, screen_width - 150*SCREEN_SCALE, 70*SCREEN_SCALE)
    draw_text('500', font, BLACK, screen_width - 70*SCREEN_SCALE, 70*SCREEN_SCALE)


# create castle
castle = Castle(castle_img_100, castle_img_50, castle_img_25, screen_width - 250*SCREEN_SCALE, screen_height - 300*SCREEN_SCALE, 0.2*SCREEN_SCALE)

# create crosshair
crosshair = Crosshair(0.025)

# create buttons
repair_button = button.Button(screen_width - 220*SCREEN_SCALE, 10*SCREEN_SCALE, repair_img, 0.5*SCREEN_SCALE)
tower_button = button.Button(screen_width - 140*SCREEN_SCALE, 10*SCREEN_SCALE, tower_img_100, 0.1*SCREEN_SCALE)
armour_button = button.Button(screen_width - 75*SCREEN_SCALE, 10*SCREEN_SCALE, armour_img, 1.5*SCREEN_SCALE)
scores_button = button.Button(screen_width, screen_height, scores_btn_img, SCREEN_SCALE)
play_button = button.Button(screen_width, screen_height, play_btn_img, SCREEN_SCALE)


# create groups
menu = Menu(screen_width, screen_height)
tower_group = pygame.sprite.Group()
bullet_group = pygame.sprite.Group()
enemy_group = pygame.sprite.Group()

# game loop
run = True
in_menu = True
show_scores = False
enter_user_name = False
username = ''
while run:
    clock.tick(FPS)
    pygame.mouse.set_visible(True)
    
    high_scores = rs.get_scores()  # get scores from database
    # event handler
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            run = False

    if in_menu:
        # Handle events for menu
        events = pygame.event.get()
        # menu.handle_events(events)

        # Draw menu on screen
        menu.draw(screen)

        # Check if play button is clicked
        play_button.rect.x = screen_width/2-play_button.image.get_width()/2
        play_button.rect.y = screen_height/2-play_button.image.get_height()/2
        if play_button.draw(screen):
            in_menu = False
            enter_user_name = True
            
        scores_button.rect.x = screen_width/2-scores_button.image.get_width()/2
        scores_button.rect.y = screen_height*0.75-scores_button.image.get_height()/2
        if scores_button.draw(screen):
            in_menu = False
            show_scores = True
            
    if enter_user_name and not rs.start_game:
        rs.enter_information(screen, clock, SCREEN_SCALE)
    if show_scores:
        keys = pygame.key.get_pressed()
        in_menu = False
        screen.blit(tabel_img, (0,0))
        high_scores = rs.get_scores()  # get scores from database
        draw_text('HIGHSCORES',font,'yellow', screen_width*0.38, screen_height*0.1)
        draw_text('PRESS ESCAPE TO GO BACK...', font,'red', screen_width*0.35, screen_height*0.9)
        # sort the entries recived from the database by the score
        for x, score in enumerate(sorted(high_scores, key=rs.takeSecond, reverse=True)):
            draw_text(f'{score[0]}',font,'white',screen_width*0.23, screen_height*(0.08*(x+1))+70)
            draw_text(f'{score[1]}',font,'white',screen_width*0.43, screen_height*(0.08*(x+1))+70)
            draw_text(f'{score[2]} Shots Fired',font,'white',screen_width*0.63, screen_height*(0.08*(x+1))+70)
        if keys[pygame.K_ESCAPE]:  # back to menu
            show_scores = False
            in_menu = True

    if rs.start_game:
        if game_over == False:
            if castle.score < high_scores[0][1]:
                high_score = high_scores[0][1]
            else:
                high_score = castle.score

            pygame.mouse.set_visible(False)
                
            # Draw background
            screen.blit(map, (0, 0))

            # Draw castle
            castle.draw()
            castle.shoot()

            # Draw towers
            tower_group.draw(screen)
            tower_group.update(enemy_group)

            # Draw crosshair
            crosshair.draw()

            # Draw bullets
            bullet_group.update()
            bullet_group.draw(screen)

            # Draw enemies
            enemy_group.update(screen, castle, bullet_group)

            # Show details
            show_info()

            # Draw buttons
            if repair_button.draw(screen):
                castle.repair()
            if tower_button.draw(screen):
                # check if there is enough money and build a tower
                if castle.money >= TOWER_COST and len(tower_group) < max_towers:
                    tower = Tower(
                        tower_img_100,
                        tower_img_50,
                        tower_img_25,
                        tower_positions[len(tower_group)][0],
                        tower_positions[len(tower_group)][1],
                        0.2
                    )
                    tower_group.add(tower)
                    # subtract money
                    castle.money -= TOWER_COST
            if armour_button.draw(screen):
                castle.armour()


            # Create enemies
            if level_difficulty < target_difficulty:
                if pygame.time.get_ticks() - last_enemy > ENEMY_TIMER:
                    # create enemies
                    e = random.randint(0, len(enemy_types) - 1)
                    enemy = Enemy(enemy_health[e], enemy_animations[e], -100, screen_height - 100, 1)
                    enemy_group.add(enemy)
                    # reset enemy timer
                    last_enemy = pygame.time.get_ticks()
                    # increase level difficulty by enemy health
                    level_difficulty += enemy_health[e]

            # Check if all the enemies have been spawned
            if level_difficulty >= target_difficulty:
                # check how many are still alive
                enemies_alive = 0
                for e in enemy_group:
                    if e.alive == True:
                        enemies_alive += 1
                # if there are none alive the level is complete
                if enemies_alive == 0 and next_level == False:
                    next_level = True
                    level_reset_time = pygame.time.get_ticks()

            # Move onto the next level
            if next_level == True:
                draw_text('LEVEL COMPLETE!', font_60, WHITE, screen_width*0.42, screen_height*0.48)
                if pygame.time.get_ticks() - level_reset_time > 1500:
                    next_level = False
                    level += 1
                    last_enemy = pygame.time.get_ticks()
                    target_difficulty *= DIFFICULTY_MULTIPLIER
                    level_difficulty = 0
                    enemy_group.empty()

                # Check game over
            if castle.health <= 0:
                game_over = True
                rs.enter_score(castle.score, castle.shots_fired)
                draw_text('GAME OVER!', font, BLACK, screen_width*0.45, screen_height*0.45)
                pygame.mouse.set_visible(True)
                
        if game_over:
            key = pygame.key.get_pressed()
            draw_text('PRESS "A" TO PLAY AGAIN!', font, BLACK, screen_width*0.45, screen_height*0.545)
            if key[pygame.K_a]:
                game_over = False
                level = 1
                target_difficulty = 1000
                level_difficulty = 0
                last_enemy = pygame.time.get_ticks()
                enemy_group=pygame.sprite.Group()
                tower_group=pygame.sprite.Group()
                castle = Castle(castle_img_100, castle_img_50, castle_img_25, screen_width - 250*SCREEN_SCALE, screen_height - 300*SCREEN_SCALE, 0.2*SCREEN_SCALE)
                pygame.mouse.set_visible(False)
                rs = RecordSystem()
                in_menu = True
                enter_user_name = False
            pygame.display.update()

    # update display window
    pygame.display.update()

pygame.quit()
