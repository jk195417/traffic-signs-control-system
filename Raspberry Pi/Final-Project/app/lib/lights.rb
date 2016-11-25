# Ruby GPIO lib
require 'pi_piper'
include PiPiper
class Lights
  def initialize(r_pin,g_pin,y_pin)
    @r = PiPiper::Pin.new(:pin => r_pin, :direction => :out)
    @g = PiPiper::Pin.new(:pin => g_pin, :direction => :out)
    @y = PiPiper::Pin.new(:pin => y_pin, :direction => :out)
  end

  def red
    @r.on
    @g.off
    @y.off
  end

  def green
    @r.off
    @g.on
    @y.off
  end

  def yellow
    @r.off
    @g.off
    @y.on
  end

  def off
    @r.off
    @g.off
    @y.off
  end
end