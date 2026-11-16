#pragma once
#include <cstdint>
#include <cstring>
#include <vector>
#include <mach-o/dyld.h>
#include <mach/vm_prot.h>
#include <mach/mach.h>

namespace SigScan {
inline void parse_pattern(const char* pattern, std::vector<uint8_t>& bytes, std::vector<bool>& mask) {
    bytes.clear(); mask.clear();
    const char* p = pattern;
    while (*p) {
        while (*p == ' ') ++p;
        if (!*p) break;
        if (*p == '?') {
            bytes.push_back(0); mask.push_back(false); ++p; if (*p == '?') ++p;
        } else {
            auto hex = [](char c) -> uint8_t {
                if (c >= '0' && c <= '9') return c - '0';
                if (c >= 'A' && c <= 'F') return c - 'A' + 10;
                if (c >= 'a' && c <= 'f') return c - 'a' + 10; return 0;
            };
            bytes.push_back((hex(p[0]) << 4) | hex(p[1]));
            mask.push_back(true); p += 2;
        }
    }
}

inline uintptr_t scan_range(uintptr_t start, size_t size, const std::vector<uint8_t>& bytes, const std::vector<bool>& mask) {
    if (bytes.empty() || size < bytes.size()) return 0;
    const uint8_t* p = (const uint8_t*)start;
    const uint8_t* end = p + size - bytes.size();
    for (; p <= end; ++p) {
        bool ok = true;
        for (size_t i = 0; i < bytes.size(); ++i) {
            if (mask[i] && p[i] != bytes[i]) { ok = false; break; }
        }
        if (ok) return (uintptr_t)p;
    }
    return 0;
}

inline uintptr_t find_in_module(const char* module_frag, const char* pattern) {
    std::vector<uint8_t> bytes; std::vector<bool> mask;
    parse_pattern(pattern, bytes, mask);
    if (bytes.empty()) return 0;
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; ++i) {
        const char* name = _dyld_get_image_name(i);
        if (!name || !strstr(name, module_frag)) continue;
        uintptr_t base = (uintptr_t)_dyld_get_image_header(i);
        vm_address_t addr = base; vm_size_t vmsize = 0;
        for (int guard = 0; guard < 200; ++guard) {
            vm_region_basic_info_data_64_t info;
            mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT_64;
            mach_port_t obj_name = MACH_PORT_NULL;
            if (vm_region_64(mach_task_self(), &addr, &vmsize, VM_REGION_BASIC_INFO_64, (vm_region_info_t)&info, &info_count, &obj_name) != KERN_SUCCESS) break;
            if (info.protection & VM_PROT_EXECUTE) {
                uintptr_t hit = scan_range(addr, vmsize, bytes, mask);
                if (hit) return hit;
            }
            addr += vmsize;
            if (addr >= base + 0x20000000) break;
        }
    }
    return 0;
}
}
