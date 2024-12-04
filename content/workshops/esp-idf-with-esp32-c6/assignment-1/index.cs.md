---
title: "Workshop: ESP-IDF a ESP32-C6 - Úkol 1"
date: 2024-09-30T00:00:00+01:00
showTableOfContents: false
series: ["WS001CZ"]
series_order: 2
showAuthor: false
---

## Úkol 1: Instalace Visual Studio Code a ESP-IDF pluginu

---

Abyste byli schopní zvládnout všechny úkoly v tomto workshopu, budete potřebovat [Visual Studio Code](https://code.visualstudio.com/) a nainstalovaný framework ESP-IDF. Prvním úkolem tedy bude nainstalovat si všechny potřebné nástroje.

V obou případech budeme postupovat podle návodu na [githubových stránkách ESP-IDF pluginu pro VS Code](https://github.com/espressif/vscode-esp-idf-extension?tab=readme-ov-file#how-to-use).

### Instalace pro Windows

1. Nainstalujte [Visual Studio Code](https://code.visualstudio.com/download)
2. Nainstalujte potřebné [ovladače](https://www.silabs.com/documents/public/software/CP210x_Universal_Windows_Driver.zip)
2. Ve VS Code otevřete **Extensions** (Ctrl + Shift + X nebo ⇧ + ⌘ + X)
3. Najděte [ESP-IDF plugin](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension) a nainstalujte ho
4. Otevřete *View -> Command Pallete* (Ctrl + Shift + P nebo ⇧ + ⌘ + P) a do nově otevřené řádky napište *Configure ESP-IDF Extension*
5. Vyberte možnost **Express** a následně vyberte Github jako download server a release/v5.3 jako ESP-IDF version
6. Klikněte na "Install"

### Instalace pro Linux a Mac

1. Nainstalujte [Visual Studio Code](https://code.visualstudio.com/download)
2. Nainstalujte [prerekvizity podle vaší distribuce](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/linux-macos-setup.html#step-1-install-prerequisites) (**Pouze step 1**, celý návod se věnuje instalaci samostatného ESP-IDF, to v současné chvíli nepotřebujeme)
3. Ve VS Code otevřete **Extensions** (Ctrl + Shift + X nebo ⇧ + ⌘ + X)
4. Najděte [ESP-IDF plugin](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension) a nainstalujte ho
5. Otevřete *View -> Command Pallete* (Ctrl + Shift + P nebo ⇧ + ⌘ + P) a do nově otevřené řádky napište *Configure ESP-IDF Extension*
6. Vyberte možnost **Express** a následně vyberte Github jako download server a release/v5.3 jako *ESP-IDF version*
7. Klikněte na "Install"


### Instalace ESP BLE Prov

Během jednoho z úkolů vyzkoušíme také Wi-Fi provisioning. K tomu budeme potřebovat aplikaci, přes kterou našemu ESPčku sdělíme SSID a heslo k síti. 

Aplikaci buď vyhledáte v appstoru příslušného systému, nebo přes odkazy níže:

- Android: [ESP BLE Provisioning](https://play.google.com/store/apps/details?id=com.espressif.provble&pcampaignid=web_share)
- iOS: [ESP BLE Provisioning](https://apps.apple.com/us/app/esp-ble-provisioning/id1473590141)

### VSCode, ESP-IDF plugin a samotné ESP-IDF

Možná jste si všimli, že během instalace ESP-IDF pluginu jste vybírali i verzi samotného ESP-IDF a měli jste mj. i možnost zvolit lokální instalaci ESP-IDF. Jak spolu tedy souvisí ESP-IDF plugin a samotné ESP-IDF?

ESP-IDF je **samostatný framework**, který lze používat i bez VSCode a pluginu. Ovládá se z příkazové řádky (nemá tedy žádné GUI) a obsahuje všechnu logiku pro build, flashování i monitorování aplikace. Když tedy zmáčknete např. tlačítko *Build* v *ESP-IDF Exploreru* (nebojte, v dalších lekcích si vysvětlíme, co to znamená), nakonec se stejně zavolá příkaz `idf.py build`. 

ESP-IDF plugin je **wrapper/adaptér**, který zpřístupňuje funkcionalitu ESP-IDF ve VSCode. Jinak řečeno, propojuje VSCode a framework ESP-IDF: vytváří GUI v podobě *ESP-IDF Exploreru* a zároveň se stará o to, aby tlačítka plnila svou funkci, výstup příkazů se korektně zobrazoval ve VSCode, aby se konfigurace frameworku správně projevila a podobně. Ke svému fungování ale potřebuje právě i frameowrk, který běží v pozadí.

Nyní byste měli mít funkční ESP-IDF plugin pro VSCode a nastavené ESP-IDF. Můžeme se tedy pustit do druhé části tutoriálu:

[Úkol 2: Vytváření projektů a Komponenty](../assignment-2)  
