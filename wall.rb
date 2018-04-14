# -*- coding: UTF-8 -*-

module TankGame

  # 墙类,包括总部
  class Wall
  
    # setter and getter
    attr_reader :type
    
    # 构造器方法    
    def initialize tg, x, y, type
      @tg, @x, @y, @type = tg, x, y, type
      @img = @tg.wall_image[@type]
      @w, @h = @img.width, @img.height 
    end
    
    # 画墙
    def draw cr      
      cr.set_source_pixbuf(@img, @x, @y).paint  # 设置来源,并画出图片      
    end
    
    # 生成碰撞检测类
    def get_rect
      Rectangle.new @x, @y, @w, @h
    end    
  end
end