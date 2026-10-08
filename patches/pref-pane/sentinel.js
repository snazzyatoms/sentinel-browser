/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

/* import-globals-from extensionControlled.js */
/* import-globals-from preferences.js */

ChromeUtils.defineLazyGetter(this, "L10n", () => {
  return new Localization([
    "branding/brand.ftl",
    "browser/preferences/preferences.ftl",
  ]);
});

if (!Services.prefs.getBoolPref("browser.settings-redesign.enabled", false)) {
  Preferences.addAll([
    // IPv6
    { id: "network.dns.disableIPv6", type: "bool" },
    // Firefox Accounts
    { id: "identity.fxaccounts.enabled", type: "bool" },
    // WebGL
    //{ id: "sentinel.webgl.prompt", type: "bool" }, // Already added (see lw-permissions.patch)
    { id: "sentinel.webgl.prompt.hide", type: "bool" },
    // Automatically Update Extensions
    { id: "extensions.update.enabled", type: "bool" },
    { id: "extensions.update.autoUpdateDefault", type: "bool" },
    // Clipboard autocopy/paste
    { id: "clipboard.autocopy", type: "bool" },
    { id: "middlemouse.paste", type: "bool" },
    // XOrigin referrers
    { id: "network.http.referer.XOriginPolicy", type: "int" },
    // Harden
    { id: "privacy.resistFingerprinting.letterboxing", type: "bool" },
    // Google Safe Browsing
    //{ id: "browser.safebrowsing.malware.enabled", type: "bool" }, // Already loaded
    //{ id: "browser.safebrowsing.phishing.enabled", type: "bool" },
    { id: "browser.safebrowsing.blockedURIs.enabled", type: "bool" },
    { id: "browser.safebrowsing.provider.google4.gethashURL", type: "string" },
    { id: "browser.safebrowsing.provider.google4.updateURL", type: "string" },
    { id: "browser.safebrowsing.provider.google.gethashURL", type: "string" },
    { id: "browser.safebrowsing.provider.google.updateURL", type: "string" },
    /**** Prefs that require changing a lockPref ****/
    // Google safe browsing check downloads
    //{ id: "browser.safebrowsing.downloads.enabled", type: "bool" }, //Also already added
    { id: "toolkit.legacyUserProfileCustomizations.stylesheets", type: "bool" },
    { id: "browser.nova.enabled", type: "bool" },
    { id: "sentinel.jit.enabled-by-default", type: "bool" },
  ]);
}

Preferences.addSetting({
  id: "sentinelExtensionUpdateEnabled",
  pref: "extensions.update.enabled",
});
Preferences.addSetting({
  id: "sentinelExtensionAutoUpdateEnabled",
  pref: "extensions.update.autoUpdateDefault",
});
Preferences.addSetting({
  id: "sentinelExtensionUpdate",
  deps: ["sentinelExtensionUpdateEnabled","sentinelExtensionAutoUpdateEnabled"],
  get: (_, deps) => deps.sentinelExtensionUpdateEnabled.value && deps.sentinelExtensionAutoUpdateEnabled.value,
  set: (value, deps) => {
      deps.sentinelExtensionUpdateEnabled.value = value;
      deps.sentinelExtensionAutoUpdateEnabled.value = value;
  },
});

Preferences.addSetting({
  id: "sentinelSync",
  pref: "identity.fxaccounts.enabled",
  onUserChange() {
    confirmRestartPrompt(
      Services.prefs.getBoolPref("identity.fxaccounts.enabled"),
      1,
      true,
      false
    ).then(buttonIndex => {
      if (buttonIndex == CONFIRM_RESTART_PROMPT_RESTART_NOW) {
          Services.startup.quit(
            Ci.nsIAppStartup.eAttemptQuit | Ci.nsIAppStartup.eRestart
          );
          return
        }
    });
  }
});

Preferences.addSetting({
  id: "sentinelAutocopy",
  pref: "clipboard.autocopy",
});
Preferences.addSetting({
  id: "sentinelPaste",
  pref: "middlemouse.paste",
});
Preferences.addSetting({
  id: "sentinelMiddleClick",
  deps: ["sentinelAutocopy","sentinelPaste"],
  get: (_, deps) => deps.sentinelAutocopy.value && deps.sentinelPaste.value,
  set: (value, deps) => {
      deps.sentinelAutocopy.value = value;
      deps.sentinelPaste.value = value;
  },
});

Preferences.addSetting({
  id: "sentinelNova",
  pref: "browser.nova.enabled",
});

Preferences.addSetting({
  id: "sentinelJIT",
  pref: "sentinel.jit.enabled-by-default",
  get: (value) => value.value = !value,
  set: (value) => value.value = !value,
});

Preferences.addSetting({
  id: "sentinelUserChrome",
  pref: "toolkit.legacyUserProfileCustomizations.stylesheets",
});

Preferences.addSetting({
  id: "sentinelIPv6",
  pref: "network.dns.disableIPv6",
  get: (value) => value.value = !value,
  set: (value) => value.value = !value,
});

Preferences.addSetting({
  id: "sentinelCrossOrigin",
  pref: "network.http.referer.XOriginPolicy",
  get: (value) => {
    if (value == 2) {
      return true;
    } else {
      return false;
    }
  },
  set: (value) => value ? 2 : 0,
});

Preferences.addSetting({
  id: "sentinelRFP",
  pref: "privacy.resistFingerprinting",
});
Preferences.addSetting({
  id: "sentinelLetterboxing",
  pref: "privacy.resistFingerprinting.letterboxing",
});

Preferences.addSetting({
  id: "sentinelWebGLPrompt",
  pref: "sentinel.webgl.prompt",
  get: (value) => value.value = !value,
  set: (value) => value.value = !value,
});
Preferences.addSetting({
  id: "sentinelWebGLPromptHide",
  pref: "sentinel.webgl.prompt.hide",
  deps: ["sentinelWebGLPrompt"],
  disabled: ({sentinelWebGLPrompt}) => {
    return sentinelWebGLPrompt.value;
  },
});


function openProfileDirectory() {
  // Get the profile directory.
  let currProfD = Services.dirsvc.get("ProfD", Ci.nsIFile);
  let profileDir = currProfD.path;

  // Show the profile directory.
  let nsLocalFile = Components.Constructor(
    "@mozilla.org/file/local;1",
    "nsIFile",
    "initWithPath"
  );
  new nsLocalFile(profileDir).reveal();
}

function openAboutConfig() {
  window.open("about:config", "_blank");
}

var gSentinelPane = {
  _pane: null,

  // called when the document is first parsed
  init() {
    this._pane = document.getElementById("paneSentinel");
    initSettingGroup("sentinelBehavior");
    initSettingGroup("sentinelNetworking");
    initSettingGroup("sentinelPrivacy");
    initSettingGroup("sentinelFingerprinting");

    // Set event listener on open profile directory button
    setEventListener("sentinel-open-profile", "command", openProfileDirectory);
    // Set event listener on open about:config button
    setEventListener("sentinel-config-link", "click", openAboutConfig);

    // Notify observers that the UI is now ready
    Services.obs.notifyObservers(window, "sentinel-pane-loaded");
  },
};
