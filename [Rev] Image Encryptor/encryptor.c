#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

static uint32_t prng_state;

void seed_prng(uint32_t seed) {
    prng_state = seed;
}

uint32_t next_prng() {
    prng_state = 16807 * prng_state;
    return prng_state;
}

uint8_t rotr8(uint8_t value, int shift) {
    shift &= 7;
    if (shift == 0) return value;
    return (value >> shift) | (value << (8 - shift));
}

uint8_t rotl8(uint8_t value, int shift) {
    shift &= 7;
    if (shift == 0) return value;
    return (value << shift) | (value >> (8 - shift));
}

static inline uint8_t transform_op_0(uint8_t byte, uint8_t key8) { return byte ^ key8; }
static inline uint8_t transform_op_1(uint8_t byte, uint8_t key8) { return byte + key8; }
static inline uint8_t transform_op_2(uint8_t byte, uint8_t key8) { return byte - key8; }
static inline uint8_t transform_op_3(uint8_t byte, uint8_t key8) { (void)key8; return ~byte; }
static inline uint8_t transform_op_4(uint8_t byte, uint8_t key8) { return rotr8(byte, key8 & 7); }
static inline uint8_t transform_op_5(uint8_t byte, uint8_t key8) { return rotl8(byte, key8 & 7); }
static inline uint8_t transform_op_6(uint8_t byte, uint8_t key8) { (void)key8; return (byte << 4) | (byte >> 4); }
static inline uint8_t transform_op_7(uint8_t byte, uint8_t key8) { return byte ^ (key8 >> 4); }
static inline uint8_t transform_op_8(uint8_t byte, uint8_t key8) { return byte ^ (key8 & 0x0F); }
static inline uint8_t transform_op_9(uint8_t byte, uint8_t key8) { return ~byte ^ key8; }
static inline uint8_t transform_op_10(uint8_t byte, uint8_t key8) { (void)key8; return byte ^ 0x55; }
static inline uint8_t transform_op_11(uint8_t byte, uint8_t key8) { (void)key8; return byte ^ 0xAA; }
static inline uint8_t transform_op_12(uint8_t byte, uint8_t key8) { return byte + (key8 >> 4); }
static inline uint8_t transform_op_13(uint8_t byte, uint8_t key8) { return byte - (key8 & 0x0F); }
static inline uint8_t transform_op_14(uint8_t byte, uint8_t key8) { return ~(byte + key8); }
static inline uint8_t transform_op_15(uint8_t byte, uint8_t key8) { return key8 - byte; }
static inline uint8_t transform_op_16(uint8_t byte, uint8_t key8) { (void)key8; return byte ^ (byte >> 4); }
static inline uint8_t transform_op_17(uint8_t byte, uint8_t key8) { (void)key8; return byte ^ (byte << 4); }
static inline uint8_t transform_op_18(uint8_t byte, uint8_t key8) { (void)key8; return rotr8(byte, 1); }
static inline uint8_t transform_op_19(uint8_t byte, uint8_t key8) { (void)key8; return rotl8(byte, 1); }
static inline uint8_t transform_op_20(uint8_t byte, uint8_t key8) { (void)key8; return rotr8(byte, 2); }
static inline uint8_t transform_op_21(uint8_t byte, uint8_t key8) { (void)key8; return rotl8(byte, 2); }
static inline uint8_t transform_op_22(uint8_t byte, uint8_t key8) { (void)key8; return rotr8(byte, 3); }
static inline uint8_t transform_op_23(uint8_t byte, uint8_t key8) { (void)key8; return rotl8(byte, 3); }
static inline uint8_t transform_op_24(uint8_t byte, uint8_t key8) { return byte ^ rotr8(key8, 4); }
static inline uint8_t transform_op_25(uint8_t byte, uint8_t key8) { return byte + rotl8(key8, 4); }
static inline uint8_t transform_op_26(uint8_t byte, uint8_t key8) { return byte - (key8 ^ 0xFF); }
static inline uint8_t transform_op_27(uint8_t byte, uint8_t key8) { return (byte * 5) + key8; }
static inline uint8_t transform_op_28(uint8_t byte, uint8_t key8) { return (byte * 3) + key8; }
static inline uint8_t transform_op_29(uint8_t byte, uint8_t key8) { return (byte * 11) + key8; }
static inline uint8_t transform_op_30(uint8_t byte, uint8_t key8) { (void)key8; return byte; }
static inline uint8_t transform_op_31(uint8_t byte, uint8_t key8) { return byte + 1; }

typedef uint8_t (*transform_func_t)(uint8_t, uint8_t);

static const transform_func_t transform_table[32] = {
    transform_op_0, transform_op_1, transform_op_2, transform_op_3,
    transform_op_4, transform_op_5, transform_op_6, transform_op_7,
    transform_op_8, transform_op_9, transform_op_10, transform_op_11,
    transform_op_12, transform_op_13, transform_op_14, transform_op_15,
    transform_op_16, transform_op_17, transform_op_18, transform_op_19,
    transform_op_20, transform_op_21, transform_op_22, transform_op_23,
    transform_op_24, transform_op_25, transform_op_26, transform_op_27,
    transform_op_28, transform_op_29, transform_op_30, transform_op_31
};

uint8_t transform(uint8_t byte, uint32_t key) {
    int selector = (key >> 16) & 31;
    uint8_t key8 = key & 0xFF;
    return transform_table[selector](byte, key8);
}

int main() {
    const uint32_t prng_seed = 0x121AB312;
    seed_prng(prng_seed);

    FILE *inputFile, *outputFile;
    const char *inputFilename = "image.jpg";
    const char *outputFilename = "encrypted_image.jpg";

    inputFile = fopen(inputFilename, "rb");
    if (inputFile == NULL) {
        perror("Error opening input file");
        return 1;
    }

    outputFile = fopen(outputFilename, "wb");
    if (outputFile == NULL) {
        perror("Error opening output file");
        fclose(inputFile);
        return 1;
    }

    uint8_t fake_header[] = {0x49, 0x73, 0x31, 0x61, 0x62, 0x43, 0x54, 0x46};
    fwrite(fake_header, sizeof(uint8_t), sizeof(fake_header), outputFile);

    int byte1, byte2;
    while ((byte1 = fgetc(inputFile)) != EOF) {
        uint32_t key1 = next_prng();
        uint8_t processed_byte1 = transform((uint8_t)byte1, key1);
        processed_byte1 = rotr8(processed_byte1, (key1 >> 8) & 7);

        byte2 = fgetc(inputFile);
        if (byte2 != EOF) {
            uint32_t key2 = next_prng();
            uint8_t processed_byte2 = transform((uint8_t)byte2, key2);
            processed_byte2 = rotr8(processed_byte2, (key2 >> 8) & 7);

            fputc(processed_byte2, outputFile);
            fputc(processed_byte1, outputFile);
        }
        else {
            fputc(processed_byte1, outputFile);
            break;
        }
    }

    fclose(inputFile);
    fclose(outputFile);
    return 0;
}