
#include <MIDI.h>
#include <Adafruit_NeoPixel.h>

#define PIN        0    // Neopixel data line pin
#define LEDS_COUNT 12   // Number of leds to drive

// Parameter 1 = number of pixels in strip
// Parameter 2 = pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
//   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
//   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
//   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
Adafruit_NeoPixel strip = Adafruit_NeoPixel(LEDS_COUNT, PIN, NEO_GRB + NEO_KHZ800);

void handleNoteOn(byte channel, byte pitch, byte velocity);
void handleNoteOff(byte channel, byte pitch, byte velocity);

MIDI_CREATE_DEFAULT_INSTANCE();

void setup()
{
    strip.begin();
    strip.show(); // Initialize all pixels to 'off'

    MIDI.setHandleNoteOn(handleNoteOn);
    MIDI.setHandleNoteOff(handleNoteOff);

    MIDI.begin(MIDI_CHANNEL_OMNI);
}

void loop()
{
    MIDI.read();
}

void handleNoteOn(byte channel, byte pitch, byte velocity)
{
}

void handleNoteOff(byte channel, byte pitch, byte velocity)
{
}

