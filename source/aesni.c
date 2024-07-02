#include <stdint.h>
#include <x86intrin.h>

#include "aes.h"

// Looped implementation of AES using AES-NI intrinsics
void looped(uint8_t *plaintext, uint8_t *ciphertext, AES_KEY *key)
{
    __m128i state = _mm_loadu_si128((__m128i *)plaintext);
    __m128i *rd_key = (__m128i *)key->rd_key;

    state = _mm_xor_si128(state, *(rd_key++));
    for (size_t i = 1; i < key->rounds; i++)
    {
        state = _mm_aesenc_si128(state, *(rd_key++));
    }
    state = _mm_aesenclast_si128(state, *rd_key);

    _mm_storeu_si128((__m128i *)ciphertext, state);
}

// Branched implementation of AES using AES-NI intrinsics
void unrolled(uint8_t *plaintext, uint8_t *ciphertext, AES_KEY *key)
{
    __m128i state = _mm_loadu_si128((__m128i *)plaintext);
    __m128i *rd_key = (__m128i *)key->rd_key;

    state = _mm_xor_si128(state, *(rd_key++));
    state = _mm_aesenc_si128(state, *(rd_key++));
    state = _mm_aesenc_si128(state, *(rd_key++));
    state = _mm_aesenc_si128(state, *(rd_key++));
    state = _mm_aesenc_si128(state, *(rd_key++));
    state = _mm_aesenc_si128(state, *(rd_key++));
    state = _mm_aesenc_si128(state, *(rd_key++));
    state = _mm_aesenc_si128(state, *(rd_key++));
    state = _mm_aesenc_si128(state, *(rd_key++));
    state = _mm_aesenc_si128(state, *(rd_key++));
    if (key->rounds > 10)
    {
        state = _mm_aesenc_si128(state, *(rd_key++));
        state = _mm_aesenc_si128(state, *(rd_key++));
        if (key->rounds > 12)
        {
            state = _mm_aesenc_si128(state, *(rd_key++));
            state = _mm_aesenc_si128(state, *(rd_key++));
        }
    }
    state = _mm_aesenclast_si128(state, *rd_key);

    _mm_storeu_si128((__m128i *)ciphertext, state);
}
