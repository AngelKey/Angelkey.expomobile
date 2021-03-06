# Releasing Android Expo Client

This document will guide you through the process of releasing a new version of Expo client for Android.

1. **Bump versions of Android project**

    **Why:** Every new version of Expo client has to have another version and version code.

    **How:** Edit `/android/app/build.gradle` and bump versions in that file.

2. **Add changelog for Play Store**

    **Why:** It's polite to inform users why they may want to upgrade to latest version of an app.
    
    **How:** Add a new file under `/fastlane/android/metadata/en-US/changelogs/[versionCode].txt` (most probably it can read “Add support for SDK XX”).

3. **Test the application**

    **Why:** For our convenience it's the CI who builds the APK. Before submitting it anywhere we want to test it properly.

    **How:** On the release branch (`sdk-XX`) from which any updates are published, open the `client_android` job for commit after step 2., download build artifact from under `/root/expo/android/app/build/outputs/apk/release/app-release.apk`.
      - Run `adb shell pm clear host.exp.exponent`
      - Enable airplane mode on the device you'll be testing it on
      - `adb install {downloaded-apk}`
      - Open the application. Ensure Home loads.
        - known issue: icons don't load in airplane mode
      - Disable airplane mode and test the application.

4. **Upload the application to backend for website and `expo-cli` to download**

    **Why:** So that developers who used `expo-cli` to download Expo client to their devices can download the update.

    **How:** This is probably a subject to change, but at the moment:
      - go to `universe/tools`
      - run `gulp add-android-apk --app {path to tested APK} --appVersion {appVersion}`

5. **Submit the application to Play Store**

    **Why:** So that our users that downloaded Expo client from Play Store can update easily.

    **How:** Open the `client` workflow from which you downloaded `app-release.apk` in step 3. and approve the `client_android_approve_google_play` job. About 45 minutes later the update should be downloadable via Play Store.


6. **Promote versions to production**

    **Why:** Right now the APK is updated only on staging. We want to push the information to production.

    **How:** This is probably a subject to change, but at the moment go to `universe` and run `pt promote-versions-to-prod`.
