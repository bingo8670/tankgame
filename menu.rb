# -*- coding: UTF-8 -*-

module TankGame

  # 菜单类
  class Menu
  
    # setter and getter
    attr_reader :menubar
    
    # 构造器方法    
    def initialize(tg)
      @tg = tg
      @menubar = Gtk::MenuBar.new                              # 创建根菜单      
      init_menu                                                # 初始化菜单
    end
    
    # 菜单初始化
    def init_menu
      menu = REXML::Document.new(File.new "menu.xml").root     # 解析菜单menu.xml文件
      menu.elements.each "Menu" do |m|                         # 遍历xml文件根目录下Menu一级目录
        menu_name = m.elements["Name"].text                    # 获取一级目录名称
        menu_obj = Gtk::Menu.new                               # 创建一级菜单容器
        menu_item_obj = Gtk::MenuItem.new :label => menu_name  # 创建一级菜单
        menu_item_obj.set_submenu menu_obj                     # 一级菜单绑定一级菜单容器
        @menubar.append menu_item_obj                          # 一级菜单添加到根菜单@menubar
        m.elements.each "MenuItem" do |mi|                     # 遍历一级目录下的MenuItem二级目录
          item_name = mi.elements["Name"].text                 # 获取二级目录的名称
          item_acti = mi.elements["Activate"].text             # 获取二级目录的事件绑定方法名称
          item_obj = Gtk::MenuItem.new :label => item_name     # 创建二级子菜单
          menu_obj.append item_obj                             # 二级子菜单添加到一级菜单容器
          item_obj.signal_connect "activate" do                # 创建二级子菜单激活事件
            send item_acti                                     # 利用方法名称绑定子菜单事件到指定方法
          end          
        end        
      end 
    end
    
    # 以下为菜单事件绑定方法,方法名与nemu.xml文件中定义一样
    def start
      p @tg.tanks
    end
    def again(msg = "游戏结束！点击确定重新开始游戏")
      @tg.run_flag = false # 线程暂停
      md = Gtk::MessageDialog.new :parent => @tg, :flags => :destroy_with_parent, :type => :info, 
        :buttons_type => :ok, :message => msg
      md.override_font Pango::FontDescription.new "DFKai-SB 12"  # 设置消息框字体
      md_msg = md.run
      md.destroy
      @tg.init if md_msg.name == "GTK_RESPONSE_OK" # 点击确定重新开始游戏,初始化所有变量
      @tg.run_flag = true  # 线程启动
    end
    def pause
      @tg.run_flag = false # 线程暂停
      md = Gtk::MessageDialog.new :parent => @tg, :flags => :destroy_with_parent, :type => :info, 
        :buttons_type => :ok, :message => "游戏已暂停！点击确定继续游戏"
      md.override_font Pango::FontDescription.new "DFKai-SB 12"  # 设置消息框字体
      md.run
      md.destroy
      @tg.run_flag = true  # 线程启动
    end
    def read
      p "read"
    end
    def save
      p "save"
    end
    def exit
      Gtk.main_quit
    end
    def empty
      p "empty"
    end
  end
end