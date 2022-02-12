<p align="center">
<img width="100" src="https://raw.githubusercontent.com/prateekmedia/sftube/main/assets/sftube.png">
</p>
<h1 align="center">SF Tube - Formerly FluTube</h1>
<p align="center"><b>Youtube client made using flutter</b></p>
<p align="center">
<a href="https://github.com/prateekmedia/sftube/releases"><img alt="GitHub release" src="https://img.shields.io/github/v/release/prateekmedia/sftube"/></a> <a href="LICENSE"><img alt="License" src="https://img.shields.io/github/license/prateekmedia/sftube?color=blue"/></a> <a href="#build-from-source"><img alt="Build from source" src="https://img.shields.io/badge/Install Manually-git-blue"/></a>
</p>

<table>
    <tr>
        <td colspan=2>
            <img src="https://github.com/prateekmedia/sftube/blob/main/assets/screenshots/linux_1.jpg?raw=true"/>
        </td>
    </tr>
    <tr>
        <td>
        <img src="https://github.com/prateekmedia/sftube/blob/main/assets/screenshots/linux_2.jpg?raw=true"/>
        </td>
        <td>
        <img src="https://github.com/prateekmedia/sftube/blob/main/assets/screenshots/linux_3.jpg?raw=true"/>
        </td>
    </tr>
</table>

<h4>Features:</h4>
<ul>
    <li>Beautiful user interface</li>
    <li>Lightweight and fast</li>
    <li>No Login Required</li>
    <li>Keep your liked videos and comments</li>
    <li>Playlists support</li>
    <li>Download videos, audios and thumbnails</li>
    <li>Ads free forever</li>
    <li>Free libre and open source (FLOSS)</li>
</ul>

### Direct app download

<a href="https://github.com/prateekmedia/sftube/releases/latest/"><img src="https://img.shields.io/badge/Download latest version-indigo?style=for-the-badge&logo=Github"/></a>  <a href="https://github.com/prateekmedia/sftube/releases/continuous/"><img src="https://img.shields.io/badge/Download nightly build-157?style=for-the-badge&logo=Github"/></a>

---

### Contribute translations

- Simply copy the content of `app_en.arb` located in `lib/translations` to your language like `app_hi.arb`
- Now Modify the values of every key for example:
`"preferences": "सेटिंग्स"`
- Now make a Pull Request or simply create an issue and upload your translations there.

### Build from source

- Download latest Flutter SDK (>=2.8.0)
- Clone this repo and then for building

```bash
# Download dependencies
flutter pub get; flutter create .

# For Direct Testing
flutter build <windows/apk/linux>
```

### Credits

This project would not be possible without [youtube_explode_dart](https://github.com/Hexer10/youtube_explode_dart/) ported from C# by [Hexer10](https://github.com/Hexer10).

### License

[![GNU GPLv3 Image](https://www.gnu.org/graphics/gplv3-127x51.png)](https://www.gnu.org/licenses/gpl-3.0.en.html)

SF Tube is a Free Software: You can use, study share and improve it at your
will. Specifically you can redistribute and/or modify it under the terms of the
[GNU General Public License](https://www.gnu.org/licenses/gpl.html) as
published by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version
