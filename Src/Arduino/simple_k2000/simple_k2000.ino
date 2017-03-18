
#include <Adafruit_NeoPixel.h>

#define PIN        6    // Neopixel data line pin
#define LEDS_COUNT 12   // Number of leds to drive

/*************
 * Functions *
 *************/

// Leds color management
void updateLedsColors();

/********
 * Init *
 ********/

Adafruit_NeoPixel strip = Adafruit_NeoPixel(LEDS_COUNT, PIN, NEO_GRB + NEO_KHZ800);
int g_current_led = 0;
// Setup function, called once at init time
void setup()
{

    strip.begin();
    strip.show(); // Initialize all pixels to 'off'

    Serial.begin(115200);
}

// Main loop function
void loop()
{
    static unsigned long elapsed = millis();

    
    // Refresh colors every 100ms in case
    // (LEDs often lose their color when touching the wires)
    if (millis() - elapsed > 100) {
        updateLedsColors();
        elapsed = millis();
        g_current_led = (g_current_led + 1) % LEDS_COUNT;
    }

}


// Set led colors based on their current state
void updateLedsColors()
{
    for (int i = 0; i < LEDS_COUNT; i++) {
        if (g_current_led == i) {
            strip.setPixelColor(i, 255, 0, 0);
        }
        else {
            strip.setPixelColor(i, 0, 255, 0);
        }
    }

    strip.show();
}

