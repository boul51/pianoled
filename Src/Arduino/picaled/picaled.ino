
#include <MIDI.h>
#include <Adafruit_NeoPixel.h>

/***********
 * Defines *
 ***********/

#define PL_DEBUG_SEND_CC 1
#define PL_DEBUG_LOOP    0

#define PIN        6    // Neopixel data line pin
#define LEDS_COUNT 88   // Number of leds to drive

/*************
 * Functions *
 *************/

// Midi events handlers
void handleNoteOn(byte channel, byte pitch, byte velocity);
void handleNoteOff(byte channel, byte pitch, byte velocity);
void handleControlChange(byte channel, byte number, byte value);

// Colorspace conversion
void hsiToRgb(float H, float S, float I, uint8_t &r, uint8_t &g, uint8_t &b)

/********************
 * Global variables *
 ********************/

// Debug
unsigned long g_dbg_elapsed = 0; // (Debug variable)
int g_dbg_note = 0;

// First note played, currently used to determine the first note with a LED
int32_t g_first_kb_note = -1;

// Color settings
float g_hue = 0;
float g_light = 1.;

/********
 * Init *
 ********/

Adafruit_NeoPixel strip = Adafruit_NeoPixel(LEDS_COUNT, PIN, NEO_GRB + NEO_KHZ800);
MIDI_CREATE_DEFAULT_INSTANCE();

// Setup function, called once at init time
void setup()
{
    g_dbg_elapsed = millis();

    strip.begin();
    strip.show(); // Initialize all pixels to 'off'

    MIDI.setHandleNoteOn(handleNoteOn);
    MIDI.setHandleNoteOff(handleNoteOff);
    MIDI.setHandleControlChange(handleControlChange);

    MIDI.begin(MIDI_CHANNEL_OMNI);
    Serial.begin(115200);
}

// Main loop function
void loop()
{
#if PL_DEBUG_LOOP == 1
    // Debug
    if (millis() - g_dbg_elapsed > 1000)
    {
        g_dbg_elapsed = millis();
        MIDI.sendNoteOn(g_dbg_note, 127, 1);
        g_dbg_note++;
        if (g_dbg_note >= 127)
            g_dbg_note = 0;
    }
#endif

    MIDI.read();
}

// Called by MIDI lib when a note on is received
void handleNoteOn(byte channel, byte pitch, byte velocity)
{
    int led_index = 0;
    uint8_t r,g,b;

    // Use first received note as first note of the keyboard
    if (g_first_kb_note == -1) {
        g_first_kb_note = pitch;
        return;
    }

    led_index = pitch - g_first_kb_note;

    // Check that we have a LED matching this note
    if (led_index < 0 || led_index >= LEDS_COUNT) {
        return;
    }

    hsiToRgb(g_hue, 1, g_light, r, g, b);
    strip.setPixelColor(led_index, r, g, b);
    strip.show();

    // Debug
#if PL_DEBUG_LOOP == 1
    g_dbg_note = pitch;
    MIDI.sendControlChange(127, led_index, channel);
#endif
}

// Called by MIDI lib when a note off is received
void handleNoteOff(byte channel, byte pitch, byte velocity)
{
    int led_index = pitch - g_first_kb_note;

    // Check that we have a LED matching this note
    if (led_index < 0 || led_index >= LEDS_COUNT) {
        return;
    }

    strip.setPixelColor(led_index, 0, 0, 0);
    strip.show();
}

// Called by MIDI lib when a control change is received
void handleControlChange(byte channel, byte number, byte value)
{
    switch (number) {
      case 0 :
        g_hue = (float)value * 360. / 127.;
        break;
      case 1 :
        g_light = (float)value / 127.;
        break;
      default :
        break;
    }
}

// Convert HSI value to RGB (stolen from http://stackoverflow.com/questions/15803986/fading-arduino-rgb-led-from-one-color-to-the-other)
/* H is in range [0:360]
   S and I in range [0:1]
   R, G, and B in range [0:255] */
void hsiToRgb(float H, float S, float I, uint8_t &r, uint8_t &g, uint8_t &b)
{
    if (H > 360) {
        H = H - 360;
    }
    H = fmod(H, 360); // cycle H around to 0-360 degrees
    H = 3.14159 * H / 180.; // Convert to radians.
    S = S > 0 ? (S < 1 ? S : 1) : 0; // clamp S and I to interval [0,1]
    I = I > 0 ? (I < 1 ? I : 1) : 0;
    if (H < 2.09439) {
        r = 255 * I / 3 * (1 + S * cos(H) / cos(1.047196667 - H));
        g = 255 * I / 3 * (1 + S * (1 - cos(H) / cos(1.047196667 - H)));
        b = 255 * I / 3 * (1 - S);
    } else if (H < 4.188787) {
        H = H - 2.09439;
        g = 255 * I / 3 * (1 + S * cos(H) / cos(1.047196667 - H));
        b = 255 * I / 3 * (1 + S * (1 - cos(H) / cos(1.047196667 - H)));
        r = 255 * I / 3 * (1 - S);
    } else {
        H = H - 4.188787;
        b = 255 * I / 3 * (1 + S * cos(H) / cos(1.047196667 - H));
        r = 255 * I / 3 * (1 + S * (1 - cos(H) / cos(1.047196667 - H)));
        g = 255 * I / 3 * (1 - S);
    }
}
