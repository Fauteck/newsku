#!/usr/bin/env python3
"""Doku-Aussagen, die sich aus dem Bestand aufzaehlen lassen.

Anlass (2026-08-26): `docs/issue-analyse.md` (heute Wiki „Feedteck: Issue-Analyse (2026-04)“) war aus dem Katalog der CLAUDE.md
gefallen und `docs/design-system.md` stand darin, obwohl es als „Legacy" galt.
In den Schwesterprojekten hat dieselbe Pruefung auf Anhieb tote Verweise
gefunden — pruefteck fuenf, todo sechzehn. Eine Tabelle in einer Markdown-Datei
ist nichts, was rot werden kann; das ist die Sorte „handgepflegte Aufzaehlung"
aus der Wiki-Notiz „Behauptungen, die niemand prueft".

Geprueft wird nur, was sich *aufzaehlen* laesst. Prosa, Beispiele und
Begruendungen bleiben aussen vor — die koennen auf diese Art nicht falsch
werden.

Gelesen wird nur der Bereich zwischen ``<!-- kontrakt:NAME -->`` und
``<!-- /kontrakt:NAME -->``, damit der Guard an einer Umformulierung nicht
bricht. Wer die Doku umbaut, muss die Zaeune stehen lassen.
"""
from __future__ import annotations

import pathlib
import re
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent

# Die Doku-Website unter docs/documentation/ ist ein eigenes Erzeugnis und
# gehoert nicht in den Entwickler-Katalog der CLAUDE.md.
AUSGENOMMEN = ('docs/documentation/',)

# Laufzeit- und Bauordner: dort stehen keine Pfade, die die Doku zusagt.
LAUFZEIT = {'target', 'build', 'node_modules', '.git'}


def lies(rel: str) -> str:
    return (REPO / rel).read_text(encoding='utf-8')


def kontrakt(rel: str, name: str) -> str:
    treffer = re.search(
        rf'<!--\s*kontrakt:{name}\s*-->(.*?)<!--\s*/kontrakt:{name}\s*-->',
        lies(rel), re.DOTALL)
    if not treffer:
        # Direkt ausgeben statt sammeln: ohne Zaeune laeuft der Rest nicht,
        # und ein stiller Abbruch mit Exit 1 waere die schlechteste Auskunft.
        print(f'  ✗ In {rel} fehlt der Bereich <!-- kontrakt:{name} --> … '
              f'<!-- /kontrakt:{name} -->. Ohne die Zaeune kann nichts geprueft werden.')
        sys.exit(1)
    return treffer.group(1)


probleme: list[str] = []


def fehler(text: str) -> None:
    probleme.append(text)


def pruefe_katalog() -> tuple[int, int]:
    block = kontrakt('CLAUDE.md', 'doku-index')
    gelistet = set(re.findall(r'\((docs/[^)]+\.md)\)', block))
    vorhanden = {
        str(p.relative_to(REPO))
        for p in (REPO / 'docs').rglob('*.md')
        if not str(p.relative_to(REPO)).startswith(AUSGENOMMEN)
    }

    for f in sorted(vorhanden - gelistet):
        fehler(f'{f} liegt in docs/, steht aber nicht im Katalog der CLAUDE.md.')
    for f in sorted(gelistet - vorhanden):
        fehler(f'Der Katalog nennt {f}, aber die Datei gibt es nicht.')
    return len(vorhanden), len(gelistet)


def kandidaten(text: str):
    """Backtick-Ausdruecke, die eindeutig ein Repo-Pfad sein wollen."""
    wurzeln = {p.name for p in REPO.iterdir() if p.is_dir() and not p.name.startswith('.')}
    for ausdruck in re.findall(r'`([^`\n]+)`', text):
        pfad = ausdruck.rstrip('/')
        if '/' not in pfad:
            continue
        if any(z in pfad for z in '<>{}$*') or '...' in pfad:
            continue
        erstes = pfad.split('/', 1)[0]
        if erstes not in wurzeln or erstes in LAUFZEIT:
            continue
        yield pfad


def pruefe_pfade() -> None:
    dateien = ['CLAUDE.md'] + [
        str(p.relative_to(REPO)) for p in (REPO / 'docs').rglob('*.md')
        if not str(p.relative_to(REPO)).startswith(AUSGENOMMEN)
    ]
    for rel in dateien:
        for pfad in kandidaten(lies(rel)):
            if not (REPO / pfad).exists():
                fehler(f'{rel} nennt den Pfad {pfad} — den gibt es nicht.')


# Heimat-Regel (2026-10-07): Konzepte, Entscheidungen und Zeitpunkt-Dokumente
# leben im Wiki `llm-wiki`; im Repo bleibt nur, was mit dem Code geaendert oder
# von einem Guard geprueft wird. Jede Datei in docs/ sagt deshalb in ihrer
# ersten Zeile, womit sie sich aendert — oder bis wann sie als Konzept in
# Arbeit ist.
MARKE = re.compile(
    r'<!--\s*heimat:\s*repo\s*[—–-]+\s*(ändert sich mit|aendert sich mit|in Arbeit bis):\s*(.+?)\s*-->')
WIKI_HINWEIS = ('Konzepte, Entscheidungen und Zeitpunkt-Dokumente gehoeren ins Wiki '
                '`llm-wiki` (Heimat-Regel in der CLAUDE.md).')


def pruefe_heimat() -> None:
    import datetime

    if not re.search(r'<!--\s*heimat-regel v\d+\s*-->.*?<!--\s*/heimat-regel\s*-->',
                     lies('CLAUDE.md'), re.DOTALL):
        fehler('CLAUDE.md: Regelblock <!-- heimat-regel vN --> … <!-- /heimat-regel --> fehlt. '
               + WIKI_HINWEIS)

    for p in sorted((REPO / 'docs').rglob('*.md')):
        rel = str(p.relative_to(REPO))
        if rel.startswith(AUSGENOMMEN) or p.name == 'README.md':
            continue
        erste = next((z for z in p.read_text(encoding='utf-8').splitlines() if z.strip()), '')
        treffer = MARKE.search(erste)
        if not treffer:
            fehler(f'{rel}: erste Zeile traegt keine Heimat-Marke '
                   f'<!-- heimat: repo — ändert sich mit: … -->. {WIKI_HINWEIS}')
            continue
        art, wert = treffer.group(1), treffer.group(2)
        if art == 'in Arbeit bis':
            try:
                bis = datetime.date.fromisoformat(wert)
            except ValueError:
                fehler(f'{rel}: „in Arbeit bis“ ist kein Datum JJJJ-MM-TT ({wert!r}). {WIKI_HINWEIS}')
                continue
            if bis < datetime.date.today():
                fehler(f'{rel}: „in Arbeit bis {wert}“ ist vorbei — Konzept ins Wiki umziehen. '
                       f'{WIKI_HINWEIS}')
            continue
        for teil in (t.strip() for t in wert.split(',')):
            if teil and not any(True for _ in REPO.glob(teil.rstrip('/'))):
                fehler(f'{rel}: Pfad hinter „ändert sich mit“ trifft nichts: {teil}. {WIKI_HINWEIS}')


def main() -> int:
    vorhanden, gelistet = pruefe_katalog()
    pruefe_pfade()
    pruefe_heimat()
    print(f'Dokumente: {vorhanden} · Index-Eintraege: {gelistet}')
    if probleme:
        print('\n'.join(f'  ✗ {p}' for p in probleme))
        return 1
    print('✔ Index deckt den Ordner, alle genannten Code-Pfade existieren, Heimat-Marken stimmen.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
