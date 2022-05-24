#include <stdint.h> // uint8_t
#include <stdlib.h>
#include <stdbool.h>
#include <string.h> // memcpy
#include <libpostal/libpostal.h>

// Typedefs to shorten long type names
typedef libpostal_address_parser_options_t options_t;
typedef libpostal_address_parser_response_t response_t;

bool initialized = false; // Should only initialize library once
options_t options;

void DoInitialization() {
    if (!libpostal_setup() || !libpostal_setup_parser()) {
        exit(EXIT_FAILURE);
    }
    initialized = true;
    options = libpostal_get_address_parser_default_options();
}

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (!initialized)
        DoInitialization();

    response_t *parsed = libpostal_parse_address((const char*) data, options);

    // Free parse result
    libpostal_address_parser_response_destroy(parsed);

    return 0;
}



