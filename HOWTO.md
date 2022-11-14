# gem5 setup for Politecnico di Torino Architetture dei Sistemi di Elaborazione course
 
A word of warning: this is a long and tedius process, mostly because the old version of gem5 that we need is not easily buildable or findable anywhere online. Most things I had to use were recovered from Wayback Machine.

## Pre-requisites
### Format \<prerequisite\> (\<version used in this tutorial\>)
- A working Linux installation (22.04)
- A working Python 3 installation (3.10)
- Git
- A working C++ compiler (g++ 10.3.0)

## Steps
- Clone the gcc git repository, checkout version 7.3.0 and build it. Go [here](BUILDING_GCC.md) for more info.
- Install python2.7 and the headers. 
```bash
sudo apt install python python-dev
```
- Install pip by doing
```bash
sudo apt update
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
sudo python2 get-pip.py
```
- Install setuptools, six and scons
```bash
sudo python2.7 -m pip install setuptools six scons
```
- Make sure you installed scons 3.1.2 by running `python2.7 -m pip list` and checking the version of scons.
- Clone the gem5 git repository from https://gem5.googlesource.com/public/gem5 and checkout this very specific commit `cf0f625b47a8e0334fc3fe8c0c2cdf5aaaf3389e`
- Install all the gem5 requirements
```bash
sudo apt install m4 zlib1g zlib1g-dev libprotobuf-dev protobuf-compiler libprotoc-dev libgoogle-perftools-dev
```
- Apply the following patch to the gem5 repository (you can also find the file [here](gem5.patch))
```diff
diff --git a/src/sim/init_signals.cc b/src/sim/init_signals.cc
index 501f4eb9d1..d06d5fc166 100644
--- a/src/sim/init_signals.cc
+++ b/src/sim/init_signals.cc
@@ -66,18 +66,25 @@
 using namespace std;

 // Use an separate stack for fatal signal handlers
-static uint8_t fatalSigStack[2 * SIGSTKSZ];
+static uint8_t* fatalSigStack = nullptr; // [2 * SIGSTKSZ];
+#define FATALSIGSTACK_SIZE (sizeof(uint8_t) * 2 * SIGSTKSZ)
+
+static void freeFatalSigStack() {
+    free(fatalSigStack);
+}

 static bool
 setupAltStack()
 {
+    fatalSigStack = static_cast<uint8_t*>(malloc(FATALSIGSTACK_SIZE));
+    atexit(freeFatalSigStack);
     stack_t stack;
 #if defined(__FreeBSD__) && (__FreeBSD_version < 1100097)
     stack.ss_sp = (char *)fatalSigStack;
 #else
     stack.ss_sp = fatalSigStack;
 #endif
-    stack.ss_size = sizeof(fatalSigStack);
+    stack.ss_size = FATALSIGSTACK_SIZE;
     stack.ss_flags = 0;

     return sigaltstack(&stack, NULL) == 0;
```
- Build gem5
```bash
CC=</path/to/built/gcc-7.3.0> CXX=</path/to/built/g++-7.3.0> python2.7 `which scons`-j$(nproc) build/ALPHA/gem5.opt
```
- You will now have a working gem5.opt in `build/ALPHA/gem5.opt`, install it wherever you want.
- To build c programs with the ALPHA toolchain you'll need to download the `alphaev67-unknown-linux-gnu.tar.bz2` from this repository.
