# -*- coding: UTF-8 -*-

module TankGame

  # 资源类
  class Source
  
    # getter and setter
    attr_reader :tank_image, :bomb_image, :wall_image
    
    # 构造器方法
    def initialize
      load_img  # def引入图片
    end
    
    # 私有方法,load_img引入图片资源
    private
    # 引入图片
    def load_img    
      @tank_image = Array.new 3 do |i|
        ["Up", "Down", "Left", "Right"].map! do |n|
          # Cairo::ImageSurface.from_png "./img/%dp/%s.png" % [i, n]  # 引入图片资源
          GdkPixbuf::Pixbuf.new :file => "./img/%dp/%s.png" % [i, n]  # 引入图片资源
        end
      end
      @bomb_image = Array.new 3 do |i|
        GdkPixbuf::Pixbuf.new :file => "./img/bomb_%d.gif" % i        
      end
      @wall_image = Array.new 5 do |i|
        GdkPixbuf::Pixbuf.new :file => "./img/wall_%d.png" % i
      end     
    end    
  end
end