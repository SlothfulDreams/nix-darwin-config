// sketchybar-dockbadges: prints "<bundle-id>\t<label>" for every Dock app
// tile showing a notification badge, the same Dock AXStatusLabel OmniWM's bar
// reads. Needs Accessibility; run it from SketchyBar (which has it) so the
// grant applies.
#include <ApplicationServices/ApplicationServices.h>
#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <string.h>

static CFTypeRef copy_attr(AXUIElementRef el, CFStringRef name) {
  CFTypeRef value = NULL;
  if (AXUIElementCopyAttributeValue(el, name, &value) != kAXErrorSuccess) return NULL;
  return value;
}

static bool is_string(CFTypeRef v, CFStringRef s) {
  return v && CFGetTypeID(v) == CFStringGetTypeID() && CFStringCompare(v, s, 0) == kCFCompareEqualTo;
}

static void print_tile(AXUIElementRef tile) {
  CFTypeRef subrole = copy_attr(tile, kAXSubroleAttribute);
  bool app = is_string(subrole, CFSTR("AXApplicationDockItem"));
  if (subrole) CFRelease(subrole);
  if (!app) return;

  CFTypeRef label = copy_attr(tile, CFSTR("AXStatusLabel"));
  CFTypeRef url = label ? copy_attr(tile, kAXURLAttribute) : NULL;
  CFURLRef bundle_url = NULL;
  if (url && CFGetTypeID(url) == CFURLGetTypeID()) bundle_url = CFRetain(url);
  else if (url && CFGetTypeID(url) == CFStringGetTypeID()) bundle_url = CFURLCreateWithString(NULL, url, NULL);
  CFBundleRef bundle = bundle_url ? CFBundleCreate(NULL, bundle_url) : NULL;
  CFStringRef id = bundle ? CFBundleGetIdentifier(bundle) : NULL;

  char id_buf[256], label_buf[64];
  if (id && label && CFGetTypeID(label) == CFStringGetTypeID() && CFStringGetLength(label) > 0 &&
      CFStringGetCString(id, id_buf, sizeof id_buf, kCFStringEncodingUTF8) &&
      CFStringGetCString(label, label_buf, sizeof label_buf, kCFStringEncodingUTF8) &&
      !strpbrk(label_buf, "\t\n"))
    printf("%s\t%s\n", id_buf, label_buf);

  if (bundle) CFRelease(bundle);
  if (bundle_url) CFRelease(bundle_url);
  if (url) CFRelease(url);
  if (label) CFRelease(label);
}

int main(void) {
  pid_t dock = 0;
  // The Dock's pid, from the window list (no AppKit needed).
  CFArrayRef windows = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
  for (CFIndex i = 0; windows && i < CFArrayGetCount(windows) && !dock; i++) {
    CFDictionaryRef w = CFArrayGetValueAtIndex(windows, i);
    if (!is_string(CFDictionaryGetValue(w, kCGWindowOwnerName), CFSTR("Dock"))) continue;
    CFNumberRef n = CFDictionaryGetValue(w, kCGWindowOwnerPID);
    if (n) CFNumberGetValue(n, kCFNumberIntType, &dock);
  }
  if (windows) CFRelease(windows);
  if (!dock) return 1;

  AXUIElementRef root = AXUIElementCreateApplication(dock);
  AXUIElementSetMessagingTimeout(root, 0.5);
  CFArrayRef children = copy_attr(root, kAXChildrenAttribute);
  for (CFIndex i = 0; children && i < CFArrayGetCount(children); i++) {
    AXUIElementRef list = (AXUIElementRef)CFArrayGetValueAtIndex(children, i);
    CFTypeRef role = copy_attr(list, kAXRoleAttribute);
    bool is_list = is_string(role, kAXListRole);
    if (role) CFRelease(role);
    if (!is_list) continue;
    CFArrayRef tiles = copy_attr(list, kAXChildrenAttribute);
    for (CFIndex j = 0; tiles && j < CFArrayGetCount(tiles); j++)
      print_tile((AXUIElementRef)CFArrayGetValueAtIndex(tiles, j));
    if (tiles) CFRelease(tiles);
  }
  if (children) CFRelease(children);
  CFRelease(root);
  return AXIsProcessTrusted() ? 0 : 2;
}
