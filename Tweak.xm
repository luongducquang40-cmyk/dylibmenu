#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>
#import "AutoResolver.hpp"
#import "Menu.h"

// ==========================================
// LƯU Ý: THAY ĐỔI TÊN CLASS/METHOD TẠI ĐÂY
// Dùng Il2CppDumper để lấy tên thật của Free Fire
// ==========================================
static const char* CLASS_CAMERA = "MainCamera";
static const char* METHOD_CAMERA = "get_main";

static const char* CLASS_PLAYER = "PlayerManager";
static const char* METHOD_PLAYER = "get_AllPlayers";

// Biến lưu địa chỉ gốc
static void* (*orig_get_camera)(void*) = nullptr;
static void* (*orig_get_players)(void*) = nullptr;

// Hook Camera
static void* hook_get_camera(void* self) {
    void* ret = orig_get_camera ? orig_get_camera(self) : nullptr;
    // TODO: Dùng ret này để tính World-to-Screen
    return ret;
}

// Hook Player List
static void* hook_get_players(void* self) {
    void* ret = orig_get_players ? orig_get_players(self) : nullptr;
    
    FFMenu *menu = [FFMenu shared];
    if ([menu isEspEnabled] || [menu isAimbotEnabled]) {
        // TODO: Duyệt danh sách player trong ret, lấy vị trí, vẽ box / kéo camera
    }
    return ret;
}

__attribute__((constructor))
static void init_tweak() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!AutoResolver::init()) {
            NSLog(@"[FF Menu] IL2CPP init failed");
            return;
        }

        // Tự động tìm hàm Camera
        void* cam = AutoResolver::resolve(CLASS_CAMERA, METHOD_CAMERA, nullptr);
        if (cam) {
            MSHookFunction(cam, (void*)hook_get_camera, (void**)&orig_get_camera);
        }

        // Tự động tìm hàm Player
        void* players = AutoResolver::resolve(CLASS_PLAYER, METHOD_PLAYER, nullptr);
        if (players) {
            MSHookFunction(players, (void*)hook_get_players, (void**)&orig_get_players);
        }

        // Bật Menu
        [[FFMenu shared] show];
    });
}
