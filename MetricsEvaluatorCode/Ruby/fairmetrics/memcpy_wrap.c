#include <stddef.h>
#include <string.h>

asm (".symver wrap_memcpy, memcpy@GLIBC_2.2.5");
void *wrap_memcpy(void *dest, const void *src, size_t n) {
  return memcpy(dest, src, n);
}
