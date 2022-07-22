## Overview

A Doomfire is essential to warm up cold camping nights!

<center><img src="doomfire.png" width=300></center>

## Running the demo

Plug the badge, enter the directory and run `make mch2022`. The demo is
also [in the hatchery](https://mch2022.badge.team/projects/doom_fire).

## Overview

This a fun effect, and a typical old-school demoscene trick. It is also very
easy to hack and modify. For a good overview of the effect itself, and why we now call it Doomfire, please refer to the excellent write up by [Fabien Sanglard](https://fabiensanglard.net/doom_fire_psx/).

Here I focus on explaining how the badge demo is done.

The project uses Silice RISC-V integration: we are going to create a hardware
framework around a RISC-V softcore, the [Ice-V dual](../ice-v/IceVDual.md).
You do not need to understand the processor specifically, only keep in mind
that it has two cores, and that a core always takes exactly 4 cycles per
instruction (so overall an instruction is executed every two cycles, interleaved
between CPU0 and CPU1).

The DooM fire is an interesting example, as we have to track the framebuffer on
the CPU side. Indeed, every frame the framebuffer is updated by reading
previous pixels values and applying a small change to them. Roughly: we move up,
dim and randomly offset previous pixels to create the flame effect.
Thus we'll be using BRAM to store the framebuffer, in CPU RAM.
Because we don't have a lot of it we will limit the resolution.

> A more advanced version would be to use the FPGA SPRAM for the framebuffer,
which could accomodate a 320x200x8 resolution. But let's keep it simple!

While we update the framebuffer each frame, we also want to send its content
towards the LCD screen. For this we will be using the [simple LCD controller](../common/lcd.si) I made for the badge. It takes care of initializing the screen and then
can send one 16 bits pixel every two cycles (one cycle per byte) through the screen parallel interface. Faster than our CPU can send them!
We are also only storing a single 'heat' value per-pixel in the fire framebuffer and
thus perform a palette lookup, CPU sid, to get the colors.

> **Note:** we could move the palette lookup to hardware, but again let's keep things
simple for this project!

To get this running smoothly -- and because we can -- we'll be using both cores.
Let's make CPU0 in charge of sending the framebuffer and CPU1 in charge of the
update of the fire effect. No real need to sync them as one *writes* to the
framebuffer while the other one *reads* from it.

## FPGA design walkthrough

Time to look at the Silice design! The design is in two parts, the RISC-V
processor instantiation and the hardware surrounding it. Here is the RISC-V CPU
declaration:

```c
riscv cpu_drawer(output uint32 rgb,        // send a pixel (RGB 24 bits)
                 output uint1  on_rgb,     // pulses high when CPU writes rgb
                 input  uint32 ready,      // true when screen is ready
                 output uint32 leds,       // set on-board LEDs
                 output uint1  on_leds,    // pulses high when CPU writes leds
                ) <
                  mem=6144,
                  core="ice-v-dual", // dual core please
                  ICEV_FAST_SHIFT=1, // fast shifts (barrel shifter)
                  ICEV_ALU_LATCH=1,  // improves fmax by latching ALU mux
                  O=3                // compile with -O3
                > {

  // =============== firmware in C language ===========================
  ...
}
```

The CPU only has outputs, since it only writes to the hardware (towards
the screen) and never reads its status (for now ... soon we'll be using this
keyboard, but one thing at a time!).

Let us start from the bottom of the list, the LEDs outputs.
We have one output called `leds` and one called `on_leds`.
Both are tightly related ; in fact, `on_leds` will pulse high whenever the CPU
writes to `leds`. So every time you see an input or output
`foo` and another one called `on_foo`, the same mechanism is automatically
created. This is the case for instance with `rgb` / `on_rgb`.

How does the CPU writes to these outputs? Silice automatically generates C code
so that the firmware can call e.g. `leds(0)` to write `0` onto the output.
The hardware sees this update as soon as the instruction is executed, and
`on_leds` pulses exactly one cycle to indicate a write from the CPU. Convenient!

Here is a quick overview of what each set of outputs do:
- `rgb` / `on_rgb` : allows the CPU to write a RGB pixel (24 bits) and forget
about it while the hardware takes care of sending the three bytes, after conversion to 16 bits.
- `ready` raises to `1` when the screen is ready, as this does not happen immediately after the FPGA starts.
- `leds` / `on_leds` : outputs to the board LEDs, also used in simulation to count
cycles between two `on_leds` pulses.

After the output we see the following lines in between `<` ... `>`
- `mem=6144,` this requests some amount of RAM for the CPU (in bytes), enough
for the framebuffer, code and stack (but most of it is framebuffer),
- `core="ice-v-dual",` this requests the ice-v-*dual* softcore,
- `ICEV_FAST_SHIFT=1,` specific to the ice-v softcores, we ask for a fast shift
(barrel shifter) that uses more LUTs but operates in one cycle,
- `ICEV_ALU_LATCH=1,` adds registers in the ALU of the ice-v processor for improved max frequency,
- `O=3`, asks for `-O3` compilation level for the firmware (default is `-O1`)

### *Firmware*

The firmware code is well summarized by the C main function:
```c
  // firmware C main
  void main() {
    leds(0); // turn off LEDs (for quiet night)
    while (ready() == 0) {} // wait for ready signal
    if (cpu_id() == 0) { // === CPU 0
      draw_fire();       // draws from framebuffer (rgb)
    } else {             // === CPU 1
      update_fire();     // updates the framebuffer
    }
  }
```
Simple, isn't it? Note the call to `cpu_id()` to identify the core ; this is
specific to the Ice-V dual. Also note that only CPU0 outputs to the hardware.
Both could, of course, but that would require synchronization (or careful
orchestration).

The pixels are actually written by these lines:
```c
  // palette lookup
  int clr  = ((*col)>>2)&31;
  col     += FIRE_W;
  int *ptr = ((int*)pal) + clr;
  // send each pixel 4 times
  for (int sv=0;sv<4;++sv) {
    rgb(*ptr);
  }
```

The most important part is `rgb(*ptr);` which sends the 24bit RGB value to the
hardware. What's with the internal loop sending four times? Well, we are working
at a quarter ofr the native screen resolution (due to BRAM size limitations) so
we are sending everything four times.

### *Hardware*

Now, let's look at the hardware side of things. How is this `rgb` output dealt
with for instance?

First, the CPU is instanced and given a name:
```c
  // instantiates our CPU as defined above
  cpu_drawer cpu;
```
Yup, it's called `cpu` (!!).

Let's see where `rgb` / `on_rgb` are read. The bulk of the logic is
captured here:
```c
  if (cpu.on_rgb) {
    // CPU requests RGB write
    // grab pixel data (convert RGB 24 bits to 16 bits)
    uint5  r     <: cpu.rgb[ 9, 5];
    uint6  g     <: cpu.rgb[16, 6];
    uint5  b     <: cpu.rgb[25, 5];
    pix_data    = {g[0,3],r,b,g[3,3]};
    // initiate sending
    pix_sending = 2b11;
  } else {
    // if we can send, shift to next
    pix_data    = can_send ? pix_data>>8    : pix_data;
    pix_sending = can_send ? pix_sending>>1 : pix_sending;
  }
```

This tracks `cpu.on_rgb`, which pulses when the CPU outputs to `rgb`. The pixel
data is grabbed into a variable (`pix_data`) and the variable `pix_sending` is
set to `2b11`. This variable indicates at which step we are within the two
bytes send sequence (as the lcd controller sends byte per byte). It is shifted every time a next byte is sent, along side `pix_data`:
```c
  // if we can send, shift to next byte
  pix_data    = can_send ? pix_data>>8    : pix_data;
  pix_sending = can_send ? pix_sending>>1 : pix_sending;
```

How do we know we can send the next byte? This is indicated by `can_send`
which is defined as:
```c
  // can we send the next byte if any is pending?
  uint1 can_send <:: pix_sending[0,1] & :lcd.ready;
```
Here, `lcd.ready` is the lcd controller indicating that it can accept the next
byte. So `can_send`, which is called an expression tracker, means *we can send
if there is still a byte to send (`pix_sending[0,1]`) qnd the lcd controller
is ready (`lcd.ready`).
The reason for the `:` in front of `lcd.ready` is a technicality: when using `<::` to
define `can_send` we are asking to use the value from the start of the cycle.
Silice cannot guarantee that for `lcd.ready` which is the output of the lcd
controller unit. So it raises a warning, which we supress by adding the `:`.

So how do we actually tell the lcd controller to send these values? This is
done by these lines:
```c
  // send to screen when possible
  lcd.valid     = can_send;
  lcd.data      = pix_data[0,8];
```
We set `lcd.valid` to `1` to send, and `lcd.data`  to the byte value to be sent.

The controller is instantiated like this:
```c
  // screen driver
  lcd_driver lcd(<:auto:>);
  //             ^^^^^^^^ use autobinding for the pins
```
Here I used autobinding, which will find all inputs/outputs of the controller
that match variables or inputs/outputs in the main unit and connect them. I
usually don't recommend autobinding, but here this is convenient to keep the
source compact and bind all these `lcd_*` pins (checkout the main unit signature).

Almost done, once final detail! Our design does not run at the native frequency
of the FPGA (which is 12MHz), but a bit faster at 25MHz. This is achieved by
adding a PLL to the design that generates a higher running clock from the base one.

This is done with these lines:
```c
) <@clock_pll> {
  // ^^^^ design uses a PLL generated clock
  //                    vvv
  uint1 clock_pll = uninitialized;
  pll pllgen(
    clock_in  <: clock,
    clock_out :> clock_pll,
  );
```

## Conclusion

That's all! Hopefully you got a sense on how simple it is to design hardware
around RISC-V cores with Silice, including some dual core fanciness.

Now it's your turn to experiment and hack, nothing can break!

You might want to start changing colors, or how the fire moves, or implement
a different demo. You may want to play with the onboard RGB LED too, or modify the
hardware side of the design.

> **Note:** Feedback is most welcome, please let me know what you thought about
this write up.
