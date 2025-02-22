
# AtomicDEX Mobile

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/komodoplatform/atomicdex-mobile/build.yml)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/komodoplatform/atomicdex-mobile)
![GitHub contributors](https://img.shields.io/github/contributors-anon/komodoplatform/atomicdex-mobile)
![GitHub last commit](https://img.shields.io/github/last-commit/komodoplatform/atomicdex-mobile)
![GitHub top language](https://img.shields.io/github/languages/top/komodoplatform/atomicdex-mobile)
![Discord](https://img.shields.io/discord/412898016371015680)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/komodoplatform/atomicdex-mobile)
![GitHub repo size](https://img.shields.io/github/repo-size/komodoplatform/atomicdex-mobile)
![Twitter Follow](https://img.shields.io/twitter/follow/komodoplatform?style=social)

<p align="center">
  <img src="https://user-images.githubusercontent.com/10762374/231314925-93ec93d2-63f7-4361-8d25-71c0e1bb3e38.png" alt="adex swap screenshot" />
</p>

Built by Komodo, AtomicDEX Mobile is a non-custodial wallet and decentralized exchange rolled into one app. Hold and trade hundreds of cryptocurrencies on your mobile phone or tablet.

# NB (Forkers/contributors):
This repository is currently in the procesundergoing safety and Flutter version upgrade. Expect major merge conflicts in the near future for any files updated from this repository. Please note that this software is under active development and is provided "as is" without any warranties or guarantees. Use at your own risk, as the authors and maintainers shall not be held liable for any issues, damages, or losses resulting from its use.

## Getting Started

Build requires up-to-date version of coins file from https://github.com/KomodoPlatform/coins

Commit hash and sah256sum of coins file is specified in `coins_ci.json`.
You may download one manually or use `fetch_coins.sh` script on linux and macOS,
 `fetch_coins.ps1` powershell script on Windows.

`fetch_coins` script depends on sha256sum and jq utils:

Ubuntu: `sudo apt-get update && sudo apt-get install -y coreutils jq`

MacOS: `brew install coreutils jq`, [Brew software](https://brew.sh/)

Windows: `choco install jq`, [Choco software](https://chocolatey.org/)


## Build and run

https://github.com/KomodoPlatform/AtomicDEX-mobile/wiki/Project-Setup#build-and-run


## Run/Build with screenshot and video recording ON

```
flutter run --dart-define=screenshot=true
```


## AtomicDEX API library (libmm2.a) version:

2.1.10108
adde21b26
http://195.201.0.6/dev/

## Flutter version

Currently using flutter 2.8.1

### Upgrading from 1.22.4

In your flutter directory:

```
git checkout 2.8.1
flutter doctor
```

In the project directory:

```
flutter clean
flutter pub get
```

### beta Flutter

`flutter version` is inconsistent regarding the access to beta versions.
Git tags can be used instead (that is, when we want to experiment with beta versions of Flutter):

    FD=`which flutter`; FD=`dirname $FD`; FD=`dirname $FD`; echo $FD; cd $FD
    git pull
    git reset --hard
    git checkout -f v1.14.3

### Kotlin vs Flutter

In Android Studio (3.6.2) the latest Kotlin plugin (1.3.71) doesn't work with Flutter “1.12.13+hotfix.7”. To fix it - [uninstall the latest Kotlin](https://github.com/flutter/flutter/issues/52077#issuecomment-600459786) - then the Kotlin version 1.3.61, bundled with the Android Studio, will reappear.

## Accessing the database

    adb exec-out run-as com.komodoplatform.atomicdex cat /data/data/com.komodoplatform.atomicdex/app_flutter/AtomicDEX.db > AtomicDEX.db
    sqlite3 AtomicDEX.db

## Localization

1. Extract messages to .arb file:
```bash
flutter pub run intl_generator:extract_to_arb --output-dir=lib/l10n lib/localizations.dart
```
2. Sync generated `intl_messages.arb` with existing locale `intl_*.arb` files:
```bash
dart run sync_arb_files.dart
```
3. ARB files can be used for input to translation tools like [Arbify](https://github.com/Arbify/Arbify), [Localizely](https://localizely.com/) etc.
4. The resulting translations can be used to generate a set of libraries:
```bash
flutter pub run intl_generator:generate_from_arb --output-dir=lib/l10n  lib/localizations.dart lib/l10n/intl_*.arb
```
5. Manual editing of generated `messages_*.dart` files might be needed to delete nullable syntax (`?` symbol), since the app doesn't support it yet.

## Generate latest coin config:

Clone the latest version of [coins](https://github.com/KomodoPlatform/coins)

Download and install the latest version of [python3](https://www.python.org/downloads/)

Open the clonned repository and run the script below in the terminal in the repo folder

```bash
python3 utils/generate_app_configs.py
```

Copy the generated `coins_config.json` file in Utils folder and paste inside assets/ folder in AtomicDEX-mobile project

## Audio samples sources

 - [ticking sound](https://freesound.org/people/FoolBoyMedia/sounds/264498/)
 - [silence](https://freesound.org/people/Mullabfuhr/sounds/540483/)
 - [start (iOs)](https://freesound.org/people/pizzaiolo/sounds/320664/)

 ## Testing

 ### 1. Manual testing
 Manual testing plan:
 https://docs.google.com/spreadsheets/d/15LAphQydTn5ljS64twfbqIMcDOUMFV_kEmMkNiHbSGc

 ### 2. Integration testing
 [Guide and coverage](integration_test/README.md)

 ### 3. Unit/Widget testing
 Not supported

## License

This Software is released under the MIT License.
