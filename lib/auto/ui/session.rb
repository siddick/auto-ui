module Auto
  module Ui
    class Session
      CMD = "xdotool"

      def set_current_window
        @wid = `xdotool getactivewindow`.split[0]
        set_current_size
      end

      def set_current_size
        list = `xdotool getwindowgeometry #{@wid} | grep Geometry`.split[1].split("x")
        @width = list[0].to_i
        @height = list[1].to_i
        self
      end

      def start_if_not(match, cmd = nil)
        cmd ||= match
        pid = `ps -h | grep "#{match}" | grep -v grep`.split[0]
        if (pid && pid.to_i > 0)
          start_with_pid(pid)
        else
          start(cmd)
        end
      end

      def start_with_pid(pid)
        @wid = `xdotool search --pid #{pid}`.split[0]
        set_current_size
      end

      def start(cmd)
        Thread.new do
          system(cmd)
        end
        sleep(2)
        set_current_window
      end

      def goto!(x, y)
        @x = x < 1 ? (@width * x).to_i : x
        @y = y < 1 ? (@height * y).to_i : y
        self
      end

      def screenshot(name = "current.png")
        system("gnome-screenshot -f #{name} -w")
        self
      end

      def crop(out, newName, size, gravity)
        if (size && gravity)
          test = ["convert", out, "-gravity", gravity, "-crop", size, newName].join(" ")
          system(test)
          return newName
        end
        return out
      end

      def wait_for(name, times = 30, size = nil, gravity = nil, &block)
        out = "img/current.png"
        times.times do
          screenshot(out)
          newOut = crop(out, "first.png", size, gravity)
          newName = crop(name, "second.png", size, gravity)
          return self if diff(newOut, newName) < 500
        end

        if block
          block.call
        else
          throw "No match for #{name}"
        end
      end

      def diff(first, second)
        out = `compare -metric mae #{first} #{second} null: 2>&1`.split[0]
        return out.to_i
      end

      def run(*args)
        system(CMD + " " + args.join(" "))
        self
      end

      def goto(x, y)
        clone.goto!(x, y)
      end

      def sleep(count = 0.4)
        Kernel.sleep(count)
        self
      end

      def close
        run("windowkill", @wid)
      end

      def move(x, y)
        run("windowmove", @wid, x, y)
      end

      def resize(x, y)
        run("windowsize", @wid, x, y)
        set_current_size
      end

      def activate
        run("windowactivate", @wid)
      end

      def click(count = 1)
        run("mousemove", @x, @y, "click", count)
      end
    end
  end
end
