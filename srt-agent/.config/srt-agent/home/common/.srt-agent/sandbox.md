# Sandbox
You run inside a macOS sandbox.
- Write temporary files only under $TMPDIR; /tmp is not writable.
- lldb cannot attach to processes
  For memory errors use AddressSanitizer:
  ASAN_LIB="$("$CC" -print-file-name=libclang_rt.asan_osx_dynamic.dylib)"
  and run uninstrumented hosts (e.g. php) with DYLD_INSERT_LIBRARIES="$ASAN_LIB".
- "Operation not permitted" means the sandbox blocked it. Report the path
  instead of working around it.
