# This is a quick guide to building GCC 7.3.0 for the purpose of this repository.

- Install all the prerequisites
`sudo apt install libzstd-dev libgmp-dev libmpfr-dev libmpc-dev flex`

- Clone the gcc git repository
- Checkout the `releases/gcc-7.3.0` tag
- Apply this patch to the gcc repository (you can also find the file [here](gcc730.patch))
```diff
diff --git a/libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cc b/libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cc
index 31a5e697eae..8cef72d021f 100644
--- a/libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cc
+++ b/libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cc
@@ -154,7 +154,6 @@ typedef struct user_fpregs elf_fpregset_t;
 # include <sys/procfs.h>
 #endif
 #include <sys/user.h>
-#include <sys/ustat.h>
 #include <linux/cyclades.h>
 #include <linux/if_eql.h>
 #include <linux/if_plip.h>
@@ -247,7 +246,7 @@ namespace __sanitizer {
 #endif // SANITIZER_LINUX || SANITIZER_FREEBSD

 #if SANITIZER_LINUX && !SANITIZER_ANDROID
-  unsigned struct_ustat_sz = sizeof(struct ustat);
+  // unsigned struct_ustat_sz = sizeof(struct ustat);
   unsigned struct_rlimit64_sz = sizeof(struct rlimit64);
   unsigned struct_statvfs64_sz = sizeof(struct statvfs64);
 #endif // SANITIZER_LINUX && !SANITIZER_ANDROID
@@ -1136,7 +1135,7 @@ CHECK_SIZE_AND_OFFSET(ipc_perm, cuid);
 CHECK_SIZE_AND_OFFSET(ipc_perm, cgid);
 #if !defined(__aarch64__) || !SANITIZER_LINUX || __GLIBC_PREREQ (2, 21)
 /* On aarch64 glibc 2.20 and earlier provided incorrect mode field.  */
-CHECK_SIZE_AND_OFFSET(ipc_perm, mode);
```
- Configure gcc, remember to set the prefix paths to where you want your gcc/g++ binaries to be installed so you can use them later, while building gem5.
```
mkdir build
cd build
../configure --disable-multilib --enable-languages=c,c++ --prefix=/path/to/install
```
```
- Build and install gcc
```
make -j$(nproc)
sudo make install
```