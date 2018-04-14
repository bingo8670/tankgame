# -*- coding: UTF-8 -*-

module TankGame

  # 子弹类
  class Missile
  
    # 常量
    SPEED = 6           # 子弹速度
    WIDTH = HEIGHT = 3  # 子弹宽高
    
    # 构造器方法
    # @tg: TankGame主类实例
    # @x, @y: 子弹坐标
    # @type: 子弹类型,区分敌,我[1P,2P]
    # @good: 区分子弹好坏
    # @dir, @color: 子弹方向,颜色
    def initialize(tg, x, y, type, good, dir)
      @tg, @x, @y, @type, @good, @dir = tg, x, y, type, good, dir      
      @color = [[0,1,1],[1,1,0],[0,0.5,0]]
    end
    
    # 画出子弹
    def draw(cr)
      cr.save do
        cr.set_source_rgb @color[@type]
        cr.rectangle @x, @y, WIDTH, HEIGHT  # 设置坐标,宽高
        cr.fill      
      end
      move
    end
    
    # 生成碰撞检测类
    def get_rect
      Rectangle.new @x, @y, WIDTH, HEIGHT
    end
    
    # 子弹打中墙
    def hit_wall(wall)
      if get_rect.intersects?(wall.get_rect)
        @tg.missiles.delete self unless wall.type == 1 || wall.type == 2
        @tg.walls.delete wall if wall.type == 0
        # 判断敌方子弹是否打中总部,打中GameOver
        if !@good && wall.type == 4
          @tg.walls.delete wall
          @tg.my1p_num = @tg.my2p_num = 0
          @tg.tank_1p = @tg.tank_2p = nil
        end
        return true
      end
      false
    end
    
    # 子弹打中墙集合
    def hit_walls(walls)
      walls.each { |w| return true if hit_wall w }
      false
    end
    
    # 子弹打中坦克
    def hit_tank(tank)
      if get_rect.intersects?(tank.get_rect) && @good != tank.good
        @tg.bombs << Bomb.new(@tg, tank.x, tank.y)
        @tg.tanks.delete tank
        @tg.reset_my1p_tank if tank.type == TankGame::TANK_TYPE[:my1p]
        @tg.reset_my2p_tank if tank.type == TankGame::TANK_TYPE[:my2p]
        @tg.missiles.delete self
        return true
      end
      false
    end
    
    # 子弹打中全部坦克
    def hit_tanks(tanks)
      tanks.each { |t| return true if hit_tank t }      
      false
    end
    
    # private以下都属于私有方法
    private
    
    # 子弹移动
    def move
      case @dir
      when Tank::DIR[:up]    then @y -= SPEED                
      when Tank::DIR[:down]  then @y += SPEED        
      when Tank::DIR[:left]  then @x -= SPEED        
      when Tank::DIR[:right] then @x += SPEED              
      end
      if @y > TankGame::HEIGHT || @y < 0 || @x > TankGame::WIDTH || @x < 0
        @tg.missiles.delete self  # 子弹出界移除
      end
    end
  end
end