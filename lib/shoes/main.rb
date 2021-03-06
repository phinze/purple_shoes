class Shoes
  include Swt
  
  def self.display
    @display
  end
  
  def self.app args={}, &blk
    args[:width] ||= 600
    args[:height] ||= 500
    args[:title] ||= 'purple shoes'
    args[:left] ||= 0
    args[:top] ||= 0

    @display ||= Swt::Display.new
    shell = Swt::Shell.new @display
    shell.setSize args[:width], args[:height]
    shell.setText args[:title]
    icon = Swt::Image.new @display, File.join(DIR, '../static/purple_shoes-icon.png')
    shell.setImage icon
    color = @display.getSystemColor Swt::SWT::COLOR_WHITE
    shell.setBackground color
    
    args[:shell] = shell
    app = App.new args
    @main_app ||= app
    app.top_slot = Flow.new app.slot_attributes(app: app, left: 0, top: 0)
    
    class << app; self end.class_eval do
      define_method(:width){shell.getSize.x}
      define_method(:height){shell.getSize.y}
    end
    
    app.instance_eval &blk
    
    call_back_procs app
    shell.open

    cl = Swt::ControlListener.new
    class << cl; self end.
    instance_eval do
      define_method(:controlResized){Shoes.call_back_procs app}
      define_method(:controlMoved){}
    end
    shell.addControlListener cl
  
    if @main_app == app
      while !shell.isDisposed do
        @display.sleep unless @display.readAndDispatch
      end
      @display.dispose
    end
    app
  end
end
