# -*- coding: UTF-8 -*-

module TankGame

  # 坦克类
  class Tank
    # 常量
    SPEED = 3
    WIDTH = HEIGHT = 30
    DIR = {up: 0, down: 1, left: 2, right: 3, stop: 4}
    
    # setter and getter
    attr_reader :good, :type
    attr_accessor :x, :y, :dir, :ptdir
    # 构造器方法
    def initialize(tg, x, y, type, good, dir)
      @tg, @x, @y, @type, @good, @dir = tg, x, y, type, good, dir
      @image = @tg.tank_image
      @bU = @bD = @bL = @bR = false
      @ptdir = DIR[:up]
      @step = rand(4..15)
      @old_x, @old_y = @x, @y
      @missile_max_number = 5
      @interval = 0
    end
    
    # 坦克画自己
    def draw(cr)      
      cr.save do
        img = @image[@type][@ptdir].scale Tank::WIDTH, Tank::HEIGHT  # 获取图片并设置宽高
        # img = img.rotate 90                                        # 图片旋转
        cr.set_source_pixbuf(img, @x, @y).paint                      # 设置来源并画出图片
      end
      move  # 移动坦克
    end 
    
    # 生成碰撞检测类
    def get_rect
      Rectangle.new @x, @y, WIDTH, HEIGHT
    end
    
    # 坦克撞墙
    def collide_wall(wall)
      if wall.type != 1 && get_rect.intersects?(wall.get_rect)  
        stay #unless wall.type == 1
        return true 
      end
      false
    end
    
    # 坦克撞墙集合
    def collide_walls(walls)
      walls.each {|w| return true if collide_wall w}      
      false
    end
    
    # 坦克撞坦克
    def collide_tank(tank)    
      if get_rect.intersects?(tank.get_rect) && tank != self        
        stay
        return true 
      end
      false
    end
    
    # 坦克撞坦克集合
    def collide_tanks(tanks)
      tanks.each {|t| return true if collide_tank t}      
      false
    end
    
    # 键盘按下事件
    def key_press(event)
      key_event event, true
    end
    
    # 键盘松开事件
    def key_release(event)
      key_event event, false
    end
    
    # 以下是私有方法
    private
    # 键盘事件
    def key_event(event, b)
      key = event.keyval      
      if @type == 1
        case key
        when Gdk::Keyval::KEY_KP_4  then fire if !b
        when Gdk::Keyval::KEY_Up    then @bU = b
        when Gdk::Keyval::KEY_Down  then @bD = b
        when Gdk::Keyval::KEY_Left  then @bL = b
        when Gdk::Keyval::KEY_Right then @bR = b
        end
      else
        case key
        when Gdk::Keyval::KEY_j then fire if !b
        when Gdk::Keyval::KEY_w then @bU = b
        when Gdk::Keyval::KEY_s then @bD = b
        when Gdk::Keyval::KEY_a then @bL = b
        when Gdk::Keyval::KEY_d then @bR = b
        end
      end
      locate_direction 
    end
    
    # 根据键盘事件改变坦克方向
    def locate_direction
      @dir = DIR[:up]    if  @bU && !@bD && !@bL && !@bR
      @dir = DIR[:down]  if !@bU &&  @bD && !@bL && !@bR
      @dir = DIR[:left]  if !@bU && !@bD &&  @bL && !@bR
      @dir = DIR[:right] if !@bU && !@bD && !@bL &&  @bR
      @dir = DIR[:stop]  if !@bU && !@bD && !@bL && !@bR
    end
    
    # 我方坦克自动挂载子弹
    def load_missile
      @interval > 20 ? @interval = 0 : @interval += 1
      @missile_max_number += 1 if @missile_max_number < 5 && @interval == 20
    end
    
    # 坦克移动
    def move
      @old_x, @old_y = @x, @y
      case @dir
      when DIR[:up]    then @y -= SPEED        
      when DIR[:down]  then @y += SPEED
      when DIR[:left]  then @x -= SPEED
      when DIR[:right] then @x += SPEED
      when DIR[:stop]
      end
      @ptdir = @dir unless @dir == DIR[:stop] # 根据坦克方向改变炮桶方向,运用Ruby的unless判断
      out
      turn_dir
      load_missile
    end
    
    # 敌人坦克自动改变方向,行走,发炮弹
    def turn_dir
      if !@good
        if @step == 0
          @step = rand(4..15)
          @dir = rand(DIR.size)
        end
        @step -= 1
        fire if rand(40) > 36
      end
    end
    
    # 判断坦克出界
    def out
      if @x > TankGame::WIDTH - WIDTH
        @x = TankGame::WIDTH - WIDTH
      elsif @x < 0
        @x = 0
      end
      if @y > TankGame::HEIGHT - HEIGHT
        @y = TankGame::HEIGHT - HEIGHT
      elsif @y < 0
        @y = 0
      end      
    end
    
    # 发射子弹
    def fire
      x = @x + WIDTH/2 - Missile::WIDTH/2
      y = @y + HEIGHT/2 - Missile::HEIGHT/2	
      if @missile_max_number > 0
        m = Missile.new @tg, x, y, @type, @good, @ptdir
        @tg.missiles << m
        @missile_max_number -= 1
      end
    end
    
    # 返回上一步
    def stay
      @x, @y = @old_x, @old_y
    end
  end
end