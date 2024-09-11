---
title: "Meeting ESP komunity - podzimní edice 2024"
date: 2024-08-28
draft: false
description: "Espressif Community Meeting - Autumn 24"
tags: ["event", "announcement", "community meeting", "czech transcript only"]
showDate : false
---

{{< badge >}}
New event!
{{< /badge >}}

## Další komunitní event se blíží

Ano! Tento rok jsme se rozhodli uspořádat dva komunitní eventy. Na základě našich i Vašich zpětných vazeb chceme tento pojmout trochu jinak a dát větší prostor workshopu. Pro event jsme také zvolili nové příjemné místo, a to hned nad prostory naší české kanceláře v Bochnerově paláci v areálu Vlněny. Pokud tě baví bastlení, programování, zkrátka cokoli kolem našich ESPéček, nebo si prostě zvědavý na naše novinky a chceš si popovídat s našimi vývojáři, tohle si nesmíš nechat ujít!

### Na co se můžeš těšit:

<article class="gallery">
  <img src="gallery/RAD_0032.webp" />
  <img src="gallery/RAD_0051.webp" />
  <img src="gallery/RAD_0060.webp" />
  <img src="gallery/RAD_0073.webp" />
  <img src="gallery/RAD_0078.webp" />
  <img src="gallery/RAD_0503.webp" />
  <img src="gallery/RAD_0526.webp" />
  <img src="gallery/RAD_0542.webp" />
</article>

- **Přednášky**: Čekají tě inspirativní přednášky od vývojářů z Espressifu, lokálních firem a zapálených nadšenců do ESP! Přijď si poslechnout nejnovější trendy, tipy a triky přímo od lidí, kteří tvoří budoucnost těchto technologií.

- **Workshop**: Připravili jsme pro tebe dvouhodinový praktický workshop, kde si budeš moci osahat vývoj na našem novém čipu **ESP32-C6** s **ESP-IDF** frameworkem. Důraz bude kladen na snadný přechod od jednodušších frameworků, jako jsou Arduino nebo MicroPython. Budeš mít jedinečnou příležitost ponořit se do vývoje s podporou odborníků! Nezapomeň si vzít **vlastní notebook**, a pokud máš, přibal si s sebou **kabel s USB-C koncovkou**. O vše ostatní se postaráme my a **devkit je po workshopu tvůj**.

- **Praktická dema**: Sestrojili jsme funkční ukázky nových čipů, které nejsou jen na obdivování, ale můžeš si je rovnou sám vyzkoušet! Přijď objevit co všechno ESP dokážou.

- **Networking**: Uvolněná atmosféra u pivka s lidmi, kteří sdílejí stejné nadšení! Poznej nové přátele, popovídej si s tech influencery a promluv si s našimi vývojáři. Toto je ideální příležitost navázat nové kontakty a sdílet své nápady s komunitou.

### Důležité informace:

- **Kdy:** 18. 10. 2024 od 15:00 do 21:00
- **Kde:** Akce proběhne v Bochnerově paláci v areálu Vlněna na adrese **Přízova 3** (vstup je z vnitrobloku Vlněny)

Místa jsou omezená, zajisti si to své co nejdříve ve formuláři níže! **Vstup je zdarma**, ale **vyžaduje registraci**. Tu prosím vyplň jen tehdy, pokud se opravdu chystáš přijít.

<iframe src="https://docs.google.com/forms/d/e/1FAIpQLSeqeP4L90wLu0om38q-wvxKYKI1_Y4Hf4T928NQI8LBW4mHhQ/viewform?embedded=true" width="640" height="1400" frameborder="0" marginheight="0" marginwidth="0">Načítání…</iframe>

Podrobnější informace o akci zveřejníme brzy, takže sleduj tuto stránku a naše další kanály. Na místě bude samozřejmě zajištěno **občerstvení, pivo i nealko**, takže se můžeš těšit na pohodový večer plný technologií a skvělé atmosféry!

Těšíme se na Tebe!

Team Espressif Systems


<div style="width: 100%"><iframe width="600" height="200" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://maps.google.com/maps?width=600&amp;height=200&amp;hl=en&amp;q=Espressif%20System%20Czech+(Espressif%20Systems%20(Czech)%20s.r.o.)&amp;t=&amp;z=15&amp;ie=UTF8&amp;iwloc=B&amp;output=embed"><a href="https://www.gps.ie/">gps systems</a></iframe></div>


<style>
.gallery {
  --size: 100px;
  display: grid;
  grid-template-columns: repeat(6, var(--size));
  grid-auto-rows: var(--size);
  margin-bottom: calc(var(--size) * 1.5);
  place-items: start center;
  gap: 5px;

  &:has(:hover) img:not(:hover),
  &:has(:focus) img:not(:focus){
    filter: brightness(0.5) contrast(0.5);
  }

  & img {
    object-fit: cover;
    width: calc(var(--size) * 2);
    height: calc(var(--size) * 2);
    clip-path: path("M90,10 C100,0 100,0 110,10 190,90 190,90 190,90 200,100 200,100 190,110 190,110 110,190 110,190 100,200 100,200 90,190 90,190 10,110 10,110 0,100 0,100 10,90Z");
    transition: clip-path 0.25s, filter 0.75s;
    grid-column: auto / span 2;
    border-radius: 5px;

    &:nth-child(5n - 1) {
      grid-column: 2 / span 2
    }

    &:hover,
    &:focus {
      clip-path: path("M0,0 C0,0 200,0 200,0 200,0 200,100 200,100 200,100 200,200 200,200 200,200 100,200 100,200 100,200 100,200 0,200 0,200 0,100 0,100 0,100 0,100 0,100Z");
      z-index: 1;
      transition: clip-path 0.25s, filter 0.25s;
    }

    &:focus {
      outline: 1px dashed black;
      outline-offset: -5px;
    }
  }
}
</style>
