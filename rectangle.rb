# -*- coding: UTF-8 -*-

module TankGame
  # 碰撞检测类
  class Rectangle  
    # getter and setter
    attr_reader :x, :y, :w, :h
    
    # 构造器方法
    def initialize x, y, w, h
      @x, @y, @w, @h = x, y, w, h
    end
    
    # 矩形碰撞检测方法
    def intersects? other_rectangle
      r = other_rectangle
      # 根据两个矩形左上角x,y计算出中心点x,y,
      x, y, x1, y1 = @x + @w/2, @y + @h/2, r.x + r.w/2, r.y + r.h/2
      # 当两个矩形横向中心点的距离小于两个矩形宽的和的一半
      # 且两个矩形纵向中心点的距离小于两个矩形高的和的一半,即碰上
      (x - x1).abs < (@w + r.w)/2 && (y - y1).abs < (@h + r.h)/2
    end
  end
end