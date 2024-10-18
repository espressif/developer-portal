---
title: "Workshop: ESP-IDF a ESP32-C6 - Úkol 5"
date: 2024-09-30T00:00:00+01:00
showTableOfContents: false
series: ["WS001CZ"]
series_order: 6
showAuthor: false
---
## Úkol 5: Wi-Fi provisioning

Wi-Fi *provisioning* je jedním z nejdůležitějších aspektů jakéhokoli IoT zařízení. Když si domů přinesete třeba chytrou zásuvku, také nemusíte od výrobce stahovat kód a ručně měnit SSID a heslo, ale všechno je řešené zpravidla přes nějakou aplikaci, která všechny tyhle údaje zásuvce poskytne. Zpravidla procházíme Wi-Fi provisioningem jen jednou při počátečním nastavení našeho zařízení, ale může se hodit i v situaci, kdy dojde např. k továrnímu resetu. 

Existuje několik metod, jak Wi-Fi provisioning zajistit. Některá zařízení lze do tzv. provisioning módu přepnout stiskem nějakého tlačítka, jiná fungují přes zmíněnou aplikaci nebo webovou stránku, a některá podporují automatický provisioning pomocí jiné technologie, třeba Bluetooth Low Energy (BLE).

ESP32 samozřejmě tuhle možnost také podporuje. Můžete se s ní setkat v projektech, jakými je třeba náš [ESP RainMaker](https://rainmaker.espressif.com/).

### Praktická ukázka, jak na Wi-Fi provisioning

V předchozím úkolu jsme si ukázali, jak s pomocí NVS nastavit a přečíst údaje z flash paměti. Oproti zapisování údajů napevno do kódu to je jistě pokrok, ale ruční zapisování údaju do flash paměti pořád není zrovna pohodlné. 

Teď si ukážeme, jak s pomocí mobilního telefonu s Androidem nebo iOS nastavit Wi-Fi údaje přes BLE.

1. **Instalace mobilní aplikace**

Nejdříve si potřebujete stáhnout aplikaci pro BLE provisioning:

- Android: [ESP BLE Provisioning](https://play.google.com/store/apps/details?id=com.espressif.provble&pcampaignid=web_share)
- iOS: [ESP BLE Provisioning](https://apps.apple.com/us/app/esp-ble-provisioning/id1473590141)

2. **Vytvoření nového projektu**

Vytvoříme nový projekt s využitím příkladu `provisioning` -> `wifi_prov_mgr`. Buď lze vytvořit pomocí příkazu níže:

```bash
idf.py create-project-from-example "espressif/network_provisioning^1.0.2:wifi_prov"
```

...nebo pomocí GUI:

1. Otevřeme si ESP-IDF Component Registry
2. Vyhledáme `espressif/network_provisioning`
3. Najedeme do záložky *Examples*
4. Vybereme `wifi_prov`
5. A zvolíme `Create Project from this Example`. V následujícím okně již stačí jen zvolit, kam projekt uložíme.

> Pro vaše existující projekty můžete použít komponentu [espressif/network_provisioning](https://components.espressif.com/components/espressif/network_provisioning).
>
> ```bash
> idf.py add-dependency "espressif/network_provisioning^0.2.0"
> ```

3. **Build, flash, a monitor**

V příkladu nebudeme nic měnit, jen  ověříme, že máme správný target, **vymažeme flash paměť** (příkazem *Erase Flash*), aplikaci sestavíme (build) a naflashujeme.

> Pokud jste přidávali komponenty manuálně (přes CLI), budete potřebovat nejprve vyčistit projekt, aby se vše korektně sestavilo:
>
> `idf.py fullclean`

Po sestavení a nahrání aplikace si otevřeme `ESP-IDF Serial Monitor`.

1. **Provisioning**

V aplikaci `ESP BLE provisioning` na vašem mobilním telefonu následujte kroky tak, jak jsou zobrazené níže: 

{{< gallery >}}
  <img src="/workshops/esp-idf-with-esp32-c6/assets/provisioning-app-1.webp" class="grid-w33" />
  <img src="/workshops/esp-idf-with-esp32-c6/assets/provisioning-app-2.webp" class="grid-w33" />
  <img src="/workshops/esp-idf-with-esp32-c6/assets/provisioning-app-3.webp" class="grid-w33" />
  <img src="/workshops/esp-idf-with-esp32-c6/assets/provisioning-app-4.webp" class="grid-w33" />
  <img src="/workshops/esp-idf-with-esp32-c6/assets/provisioning-app-5.webp" class="grid-w33" />
{{< /gallery >}}

QR kód vám vaše vývojová deska vypíše do seriové linky (seriový monitor otevřete příkazem *Monitor* v *ESP-IDF Exploreru*).

Poté, co se dokončí provisioning proces, se zařízení připojí ke zvolené Wi-Fi síti.

## Další krok

Když už víme, jak se jednoduše připojovat na Wi-Fi, pojďme si to udělat bezpečnější!

[Úkol 6: Protokoly](../assignment-6)
