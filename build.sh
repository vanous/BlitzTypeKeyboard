#!/usr/bin/env bash
set -euo pipefail

# BlitzTypeKeyboard build helper for Debian

SDK_ROOT="${ANDROID_SDK_ROOT:-}"
if [[ -z "$SDK_ROOT" ]]; then
  if [[ -d "$HOME/Android/sdk" ]]; then
    SDK_ROOT="$HOME/Android/sdk"
  else
    SDK_ROOT="/usr/lib/android-sdk"
  fi
fi
JAVA_11="/usr/lib/jvm/java-11-openjdk-amd64"
JAVA_8="/usr/lib/jvm/java-8-openjdk-amd64"

if [[ -d "$JAVA_11" ]]; then
  export JAVA_HOME="$JAVA_11"
elif [[ -d "$JAVA_8" ]]; then
  export JAVA_HOME="$JAVA_8"
else
  echo "ERROR: JDK 11 (preferred) or JDK 8 not found." >&2
  echo "Install with: sudo apt install -y openjdk-11-jdk" >&2
  exit 2
fi

if [[ ! -d "$SDK_ROOT" ]]; then
  echo "ERROR: ANDROID_SDK_ROOT not found at $SDK_ROOT" >&2
  echo "Set ANDROID_SDK_ROOT to your SDK path, or install Debian packages:" >&2
  echo "  sudo apt install android-sdk-platform-tools android-sdk-build-tools android-sdk-platform-23" >&2
  exit 2
fi

if [[ ! -d "$SDK_ROOT/platforms" ]]; then
  echo "ERROR: Android SDK platforms not found in $SDK_ROOT/platforms" >&2
  echo "On Debian, install: sudo apt install android-sdk-platform-23" >&2
  echo "Or with Google SDK tools: sdkmanager \"platforms;android-29\"" >&2
  exit 2
fi

if [[ ! -d "$SDK_ROOT/platforms/android-29" ]]; then
  echo "ERROR: Required platform not found: $SDK_ROOT/platforms/android-29" >&2
  echo "Install with: sdkmanager \"platforms;android-29\"" >&2
  exit 2
fi

if [[ ! -d "$SDK_ROOT/build-tools/29.0.3" ]]; then
  echo "ERROR: Required build-tools not found: $SDK_ROOT/build-tools/29.0.3" >&2
  echo "Install with: sdkmanager \"build-tools;29.0.3\"" >&2
  exit 2
fi

export ANDROID_SDK_ROOT="$SDK_ROOT"
export PATH="$JAVA_HOME/bin:$SDK_ROOT/platform-tools:$PATH"
if [[ -z "${GRADLE_USER_HOME:-}" ]]; then
  if [[ -w "${HOME}/.gradle" ]] || mkdir -p "${HOME}/.gradle" 2>/dev/null; then
    export GRADLE_USER_HOME="${HOME}/.gradle"
  else
    export GRADLE_USER_HOME="/tmp/gradle-home"
  fi
fi

echo "JAVA_HOME=$JAVA_HOME"
java -version

./gradlew build
