## Sentinel preferences

# Sidebar
pane-sentinel-title2 = Sentinel
  .title = Sentinel
category-sentinel =
    .tooltiptext = about:config changes, logically grouped and easily accessible
# Main content
sentinel-header = Sentinel Preferences
sentinel-warning-title = Heads up!
sentinel-warning-description = We carefully choose default settings to focus on privacy and security. When changing these settings, read the descriptions to understand the implications of those changes.
# Page Layout
sentinel-general-heading2 =
    .label = Browser Behavior
sentinel-extension-update-checkbox2 =
    .label = Update add-ons automatically
    .description = Keep extensions up to date without manual intervention. A good choice for your security.
sentinel-sync-checkbox2 =
    .label = Enable Firefox Sync
    .description = Sync your data with other browsers. Requires restart.
sentinel-autocopy-checkbox2 =
    .label = Enable middle click paste
    .description = Select some text to copy it, then paste it with a middle-mouse click.
sentinel-styling-checkbox2 =
    .label = Allow userChrome.css customization
    .description = Enable this if you want to customize the UI with a manually loaded theme.
sentinel-nova-checkbox2 =
    .label = Enable the Nova redesign
sentinel-network-heading2 =
    .label = Networking
sentinel-ipv6-checkbox2 =
    .label = Enable IPv6
    .description = Allow { -brand-short-name } to connect using IPv6.
sentinel-privacy-heading2 =
    .label = Privacy
sentinel-xorigin-ref-checkbox2 =
    .label = Limit cross-origin referrers
    .description = Send a referrer only on same-origin.
sentinel-broken-heading2 =
    .label = Fingerprinting
sentinel-jit-checkbox2 =
    .label = Disable JavaScript JIT by default
    .description = This disables JIT execution by default to reduce the attack surface, while allowing it on a per-site basis.
sentinel-webgl-checkbox2 =
    .label = Always allow WebGL
    .description = This will always allow WebGL without requiring permission.
sentinel-webgl-prompt-checkbox2 =
    .label = Hide the WebGL per-site popup
    .description = This hides the popup that appears when a site tries to create a WebGL context. You can still manually bring up the prompt by clicking the icon in the searchbar.
sentinel-rfp-checkbox2 =
    .label = Enable ResistFingerprinting
    .description = Enables all available fingerprint mitigations, but can cause some websites to function improperly.
sentinel-letterboxing-checkbox2 =
    .label = Enable letterboxing
    .description = Letterboxing applies margins around your windows, in order to return a limited set of rounded resolutions.
sentinel-security-heading2 =
    .label = Security
sentinel-ocsp-checkbox =
    .label = Enforce OCSP hard-fail
sentinel-goog-safe-checkbox =
    .label = Enable Google Safe Browsing
sentinel-goog-safe-download-checkbox =
    .label = Scan downloads
# In-depth descriptions
sentinel-ocsp-description = Prevent connecting to a website if the OCSP check cannot be performed.
sentinel-ocsp-warning1 = This increases security, but it will cause breakage when an OCSP server is down.
sentinel-goog-safe-description = If you are worried about malware and phishing, consider enabling it.
sentinel-goog-safe-warning1 = Disabled over censorship concerns but recommended for less advanced users. All the checks happen locally.
sentinel-goog-safe-download-description = Allow Safe Browsing to scan your downloads to identify suspicious files.
sentinel-goog-safe-download-warning1 = All the checks happen locally.
# Footer
sentinel-footer = Useful links
sentinel-config-link = All advanced settings (about:config)
sentinel-open-profile = Open user profile directory

## Privacy & Security preferences

content-blocking-section-top-level-description = Sentinel supports - and it enables by default - Enhanced Tracking Protection in Strict mode. This is one of the most important settings in the browser, as it provides state partitioning, strict blocking lists and other neat privacy features. We do not recommend changing to other modes.

sentinel-etp =
    .label = Enhanced Tracking Protection
    .description = Sentinel supports - and it enables by default - Enhanced Tracking Protection in Strict mode. This is one of the most important settings in the browser, as it provides state partitioning, strict blocking lists and other neat privacy features. We do not recommend changing to other modes.

sentinel-swap-settings = Swap settings design
    .title = Swap settings design
    
sentinel-mouse-heading2 =
    .label = Mouse behavior

sentinel-JXL =
    .label = Enable JXL (JPEG XL) support

sentinel-h264 =
    .label = Enable the OpenH264 plugin
    .description = Required for screen sharing on some websites, such as Discord.

## Permissions

# (This label matches Fenix's preference_phone_feature_media_key_system_access string:
# https://searchfox.org/firefox-main/rev/e28b34ab/mobile/android/fenix/app/src/main/res/values/strings.xml#2117)
permissions-eme2 =
    .label = DRM-controlled content

permissions-webgl2 =
    .label = WebGL

permissions-canvas2 =
    .label = Canvas extraction

permissions-jit2 =
    .label = JavaScript JIT

## General
sentinel-rfp-warning =
    .message = This feature is disabled because ResistFingerprinting is enabled. This means Sentinel will force web content to display in a light theme.

# Home and startup

sentinel-is-default-browser-2 =
    .message = { -brand-short-name } is set as your default browser.

sentinel-is-not-default-browser-2 =
    .message = { -brand-short-name } isn't set as your default browser.

# Updates
update-application-disabled-choose-2 =
    .label = Disable the updater
    .accesskey = D

update-application-updates-disabled =
    .message = The built-in updater has been disabled. Updates must be managed manually or through an external update mechanism.
