#pragma once
#include <cstdint>
#include <dlfcn.h>
#include <string>
#include <cstring>
#include "PatternScan.hpp"

struct Il2CppDomain; struct Il2CppAssembly; struct Il2CppImage; struct Il2CppClass; struct MethodInfo;

namespace AutoResolver {
    typedef Il2CppDomain* (*t_domain_get)();
    typedef const Il2CppAssembly** (*t_domain_assemblies)(const Il2CppDomain*, size_t*);
    typedef Il2CppImage* (*t_assembly_image)(const Il2CppAssembly*);
    typedef Il2CppClass* (*t_class_name)(const Il2CppImage*, const char*, const char*);
    typedef const MethodInfo* (*t_class_method)(Il2CppClass*, const char*, int);
    typedef void* (*t_method_ptr)(const MethodInfo*);
    typedef const char* (*t_image_name)(Il2CppImage*);

    inline t_domain_get api_domain_get = nullptr;
    inline t_domain_assemblies api_domain_assemblies = nullptr;
    inline t_assembly_image api_assembly_image = nullptr;
    inline t_class_name api_class_name = nullptr;
    inline t_class_method api_class_method = nullptr;
    inline t_method_ptr api_method_ptr = nullptr;
    inline t_image_name api_image_name = nullptr;

    inline bool init() {
        void* handle = dlopen("@executable_path/Frameworks/UnityFramework.framework/UnityFramework", RTLD_NOW);
        if (!handle) handle = dlopen("UnityFramework", RTLD_NOW);
        if (!handle) return false;

        api_domain_get = (t_domain_get)dlsym(handle, "il2cpp_domain_get");
        api_domain_assemblies = (t_domain_assemblies)dlsym(handle, "il2cpp_domain_get_assemblies");
        api_assembly_image = (t_assembly_image)dlsym(handle, "il2cpp_assembly_get_image");
        api_class_name = (t_class_name)dlsym(handle, "il2cpp_class_from_name");
        api_class_method = (t_class_method)dlsym(handle, "il2cpp_class_get_method_from_name");
        api_method_ptr = (t_method_ptr)dlsym(handle, "il2cpp_method_get_pointer");
        api_image_name = (t_image_name)dlsym(handle, "il2cpp_image_get_name");

        if (!api_domain_get) {
            const char* pat = "FF 03 01 D1 FD 7B BF A9 ?? ?? ?? ?? ?? ?? ?? ?? 08 00 40 B9";
            uintptr_t addr = SigScan::find_in_module("UnityFramework", pat);
            if (addr) api_domain_get = (t_domain_get)addr;
        }
        return api_domain_get != nullptr;
    }

    inline void* find_method(const char* assembly, const char* namespaze, const char* klass, const char* method, int argc = 0) {
        if (!api_domain_get) return nullptr;
        Il2CppDomain* dom = api_domain_get();
        size_t count = 0;
        auto assemblies = api_domain_assemblies(dom, &count);
        for (size_t i = 0; i < count; ++i) {
            Il2CppImage* img = api_assembly_image(assemblies[i]);
            if (!img) continue;
            if (assembly && api_image_name) {
                const char* n = api_image_name(img);
                if (n && !strstr(n, assembly)) continue;
            }
            Il2CppClass* c = api_class_name(img, namespaze, klass);
            if (c) {
                const MethodInfo* m = api_class_method(c, method, argc);
                if (m) return api_method_ptr(m);
            }
        }
        return nullptr;
    }

    inline void* resolve(const char* class_name, const char* method_name, const char* fallback_pattern) {
        void* addr = find_method("Assembly-CSharp.dll", "", class_name, method_name, 0);
        if (addr) {
            NSLog(@"[AutoResolver] Found %s::%s via IL2CPP at %p", class_name, method_name, addr);
            return addr;
        }
        if (fallback_pattern) {
            uintptr_t scan_addr = SigScan::find_in_module("UnityFramework", fallback_pattern);
            if (scan_addr) {
                NSLog(@"[AutoResolver] Found %s::%s via Pattern Scan at 0x%lx", class_name, method_name, scan_addr);
                return (void*)scan_addr;
            }
        }
        NSLog(@"[AutoResolver] FAILED: %s::%s", class_name, method_name);
        return nullptr;
    }
}
