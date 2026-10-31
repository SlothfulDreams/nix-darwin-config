// sketchybar-menubar: hides SketchyBar while macOS's (auto-hidden) menu bar is
// on screen and slides it back once the menu bar is gone, so the two never
// overlap. The native bar shows up as an on-screen "Window Server" window at
// the top edge while it is visible or sliding (and is gone from the list
// otherwise), so that is all we poll.
#include <ApplicationServices/ApplicationServices.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>

#define MENU_BAR_LAYER 24
// Must match the bar height in sketchybarrc: the bar slides in from this far up.
#define SLIDE_FROM "-40"

static volatile sig_atomic_t stopping = 0;
static void on_stop(int sig) { (void)sig; stopping = 1; }

static bool menu_bar_revealed(void) {
  CFArrayRef list = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
  if (!list) return false;
  bool found = false;
  for (CFIndex i = 0; i < CFArrayGetCount(list) && !found; i++) {
    CFDictionaryRef w = CFArrayGetValueAtIndex(list, i);
    int layer = -1;
    CFNumberRef n = CFDictionaryGetValue(w, kCGWindowLayer);
    if (n) CFNumberGetValue(n, kCFNumberIntType, &layer);
    if (layer != MENU_BAR_LAYER) continue;
    CFStringRef owner = CFDictionaryGetValue(w, kCGWindowOwnerName);
    if (owner && CFStringCompare(owner, CFSTR("Window Server"), 0) == kCFCompareEqualTo) found = true;
  }
  CFRelease(list);
  return found;
}

static void run(const char *cmd) {
  int rc = system(cmd);
  (void)rc; // SketchyBar may not be running yet; nothing to do about it here.
}

int main(void) {
  bool hidden = false;
  int polls_revealed = 0, polls_gone = 0;
  // Start from a known state: a previous instance may have died while hidden.
  run("sketchybar --bar hidden=off y_offset=0 >/dev/null 2>&1");
  signal(SIGTERM, on_stop);
  signal(SIGINT, on_stop);
  while (!stopping) {
    usleep(30000);
    if (menu_bar_revealed()) {
      polls_gone = 0;
      polls_revealed++;
      // Re-assert once a second: a SketchyBar reload meanwhile would unhide it.
      if (!hidden || polls_revealed % 33 == 0) {
        run("sketchybar --bar hidden=on >/dev/null 2>&1");
        hidden = true;
      }
    } else if (hidden && ++polls_gone >= 2) {
      // The native bar's slide-up has finished (it leaves the window list).
      run("sketchybar --bar hidden=off y_offset=" SLIDE_FROM " --animate sin 10 --bar y_offset=0 >/dev/null 2>&1");
      hidden = false;
      polls_revealed = 0;
    }
  }
  // Don't leave SketchyBar hidden behind when stopped (e.g. launchd bootout).
  if (hidden) run("sketchybar --bar hidden=off y_offset=0 >/dev/null 2>&1");
  return 0;
}
