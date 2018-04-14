# -*- coding: UTF-8 -*-

require 'gtk3'
require 'rexml/document'
Dir["./*.rb"].each{|f| require f if f!="./tank_game.rb"}

module TankGame

  # 坦克大战主类
  class TankGame < Gtk::Window

    # 常量
    WIDTH, HEIGHT = 800, 600
    MENU_HEIGHT = 25
    TANK_TYPE = {enemy: 0, my1p: 1, my2p: 2}

    # setter and getter
    attr_reader :missiles, :tanks, :bombs, :walls, :tank_image, :bomb_image, :wall_image
    attr_accessor :run_flag, :my1p_num, :my2p_num, :tank_2p, :tank_1p

    # 构造器方法
    def initialize
      super
      source      = Source.new
      @tank_image = source.tank_image # 获取坦克图片资源
      @bomb_image = source.bomb_image # 获取爆炸图片资源
      @wall_image = source.wall_image # 获取墙类图片资源
      @run_flag   = true              # 线程启动标记
      @checkpoint = 1                 # 关卡
      @appear     = 5                 # 坦克同时出现数量



      # xml解析地图
      @maps = REXML::Document.new(File.new "map.xml").root

      init        # 初始化变量
      init_ui     # def初始化ui界面
      listeners   # def事件监听
      show_all    # 显示所有部件
      run         # def启动线程
    end
    # 初始化变量
    def init
      @tank_num = 30            # 敌方坦克数量
      @my1p_num = @my2p_num = 3 # 我方坦克数量
      @tanks    = Array.new     # 初始化敌人坦克数组
      @missiles = Array.new     # 初始化子弹数组
      @bombs    = Array.new     # 初始化爆炸数组
      @walls    = Array.new     # 初始化墙类数组
      @tank_1p = Tank.new self, 325, 570, TANK_TYPE[:my1p], true, Tank::DIR[:stop]  # 生成1P坦克
      @tank_2p = Tank.new self, 445, 570, TANK_TYPE[:my2p], true, Tank::DIR[:stop]  # 生成2P坦克
      init_tanks              # def初始化创建坦克
      init_walls @checkpoint  # def初始化创建墙,并指定关数
    end
    # 重置1P坦克
    def reset_my1p_tank
      @my1p_num -= 1
      if @my1p_num > 0 && @tank_1p != nil
        @tank_1p.x, @tank_1p.y = 325, 570
        @tank_1p.dir, @tank_1p.ptdir = Tank::DIR[:stop], Tank::DIR[:up]
      else
        @tank_1p = nil
      end
    end
    # 重置2P坦克
    def reset_my2p_tank
      @my2p_num -= 1
      if @my2p_num > 0 && @tank_2p != nil
        @tank_2p.x, @tank_2p.y = 445, 570
        @tank_2p.dir, @tank_2p.ptdir = Tank::DIR[:stop], Tank::DIR[:up]
      else
        @tank_2p = nil
      end
    end
    # 初始化ui界面
    def init_ui
      set_title "坦克世界"                                                          # 设置窗口标题
      set_resizable false                                                           # 禁止改变窗口大小
      set_icon @tank_image[TANK_TYPE[:my2p]][Tank::DIR[:up]]                        # 设置任务栏窗口图标,使用2p的坦克作为图标
      # set_icon_from_file "./img/1P/Up.png"                                        # 设置任务栏窗口图标
      override_background_color :normal, Gdk::RGBA::new(0.6, 0.6, 0.6, 1)           # 设置窗口背景色
      set_default_size WIDTH, HEIGHT + MENU_HEIGHT                                  # 设置窗口宽高
      set_window_position :center                                                   # 设置窗口位置

      @darea = Gtk::DrawingArea.new                                                 # 创建画布
      @box = Gtk::Box.new :vertical, 0                                              # 创建盒子 :vertical垂直, :horizontal水平

      @menu = Menu.new(self)
      @menubar = @menu.menubar
      @box.pack_start @menubar, :expand => false, :fill => false, :padding => 0     # 添加菜单到box盒子
      @box.pack_start @darea, :expand => true, :fill => true, :padding => 0         # 添加画布到box盒子

      # widget:@darea对象, cr: 是@darea.window.create_cairo_context创建的对象
      @darea.signal_connect "draw" do |widget, cr|                                  # 监听draw动作
        draw cr
      end
      add @box                                                                      # 画面box盒子到窗口
      # add @darea                                                                  # 画面添加到窗口
    end

    # 事件监听
    def listeners
      # 窗口销毁事件
      signal_connect "destroy" do
        Gtk.main_quit
      end
      # 键盘按下事件
      signal_connect "key_press_event" do |widget, event|
        @tank_1p.key_press event unless @tank_1p == nil
        @tank_2p.key_press event unless @tank_2p == nil
      end
      # 键盘松开事件
      signal_connect "key_release_event" do |widget, event|
        @tank_1p.key_release event if @tank_1p != nil
        @tank_2p.key_release event if @tank_2p != nil
      end
    end

    # 画出所有东西
    def draw cr
      # 写字
      cr.save do # 等同于cr.save和cr.restore同时使用
        cr.set_source_rgb 1, 1, 1
        cr.select_font_face "华文宋体", Cairo::FONT_SLANT_NORMAL, Cairo::FONT_WEIGHT_NORMAL
        cr.set_font_size 13
        cr.move_to 20, 15
        cr.show_text "子弹数量: %d" % @missiles.size
        cr.move_to 20, 30
        cr.show_text "坦克数量: %d" % @tanks.size
        cr.move_to 120, 15
        cr.show_text "炸弹数量: %d" % @bombs.size
        cr.move_to 120, 30
        cr.show_text "墙的数量: %d" % @walls.size
        cr.move_to 220, 15
        cr.show_text "1P的数量: %d" % @my1p_num
        cr.move_to 220, 30
        cr.show_text "2P的数量: %d" % @my2p_num
        cr.move_to 320, 15
        cr.show_text "敌人坦克: %d" % @tank_num
        cr.stroke # 写字也要结尾
      end
      # 画草墙以外所有墙
      @walls.each {|w| w.draw cr unless w.type == 1}
      # 画所有子弹
      @missiles.each do |m|
        m.hit_tanks @tanks
        m.hit_walls @walls
        m.hit_tank @tank_1p if @tank_1p != nil
        m.hit_tank @tank_2p if @tank_2p != nil
        m.draw cr
      end
      # 画我方坦克
      if @tank_1p != nil
        @tank_1p.collide_walls @walls
        @tank_1p.collide_tank @tank_2p if @tank_2p != nil
        @tank_1p.collide_tanks @tanks
        @tank_1p.draw cr
      end
      if @tank_2p != nil
        @tank_2p.collide_walls @walls
        @tank_2p.collide_tank @tank_1p if @tank_1p != nil
        @tank_2p.collide_tanks @tanks
        @tank_2p.draw cr
      end
      # 画敌人坦克
      @tanks.each do |t|
        t.collide_tank @tank_1p if @tank_1p != nil
        t.collide_tank @tank_2p if @tank_2p != nil
        t.collide_tanks @tanks
        t.collide_walls @walls
        t.draw cr
      end
      # 画所有草墙
      @walls.each { |w| w.draw cr if w.type == 1 }
      # 画所有爆炸
      @bombs.each { |b| b.draw cr }
      # 我方坦克数量为0,调用菜单的重新游戏
      if @my1p_num + @my2p_num == 0
        @menu.again
      end
      # 按照敌人坦克总数量不断生成坦克
      if @tanks.size < @appear && @tank_num > 0
        generate_tanks
      end
      # 敌人坦克数量小于0,顺利通关
      if @tanks.size == 0 && @tank_num == 0
        @checkpoint += 1 if @checkpoint < 6
        @menu.again "顺利通关"
      end
    end
    # 生成坦克
    def generate_tanks
      if @tank_temp == nil
        i = rand(@appear - 1)
        @tank_temp = Tank.new(self, i*((WIDTH-30)/(@appear-1)), 0, TANK_TYPE[:enemy], false, Tank::DIR[:down])
      elsif @tank_temp.collide_tanks(@tanks) == false
        @tanks << @tank_temp
        @tank_temp = nil
        @tank_num -= 1
      end
    end
    # 初始化坦克
    def init_tanks
      @appear.times do |i|
        @tanks << Tank.new(self, i*((WIDTH-30)/(@appear-1)), 0, TANK_TYPE[:enemy], false, Tank::DIR[:down]) # 默认间隔385
        @tank_num -= 1
      end
    end

    # 初始化墙
    def init_walls num
      map = @maps.elements[num].text.split ";"
      map.each do |m|
        n = m.split(",").map{ |i| i.to_i }
        @walls << Wall.new(self, n[0]*20, n[1]*20, n[2])
      end
      @walls << Wall.new(self, 380, 560, 4)  # 总部
    end

    # 重画函数
    def redraw
      @darea.queue_draw #部件重画函数,会自动调用draw事件
    end

    # 开启线程自动重画
    def run
      t = Thread.new {         # 线程创建
        while true             # 无限循环
          sleep(0.05)          # 线程阻塞
          redraw if @run_flag  # 调用重画
        end
      }
    end
  end
end

tank = TankGame::TankGame.new # 实例化窗口对象
Gtk.main                      # 启动窗口程序
