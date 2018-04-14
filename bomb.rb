# -*- coding: UTF-8 -*-

module TankGame

  # 爆炸类
  class Bomb
  
    # 构造器方法
    def initialize tg, x, y
      @tg, @x, @y = tg, x, y
      @step = 0      
    end
    
    # 画爆炸
    def draw cr
      img = @tg.bomb_image[@step/4].scale Tank::WIDTH, Tank::HEIGHT  # 设置图片宽高   
      cr.set_source_pixbuf(img, @x, @y).paint                        # 设置来源,并画出图片
      @step == 11 ? @tg.bombs.delete(self) : @step += 1              # 以动画形式切换图片
    end
  end  
end