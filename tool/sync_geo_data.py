#!/usr/bin/env python3
"""
Generates Flutter geo assets from the dr5hn/countries-states-cities-database.

Output layout:
  assets/geo/countries.json          — 250 countries, name + translations + emoji
  assets/geo/states/{ISO2}.json      — states for each country, with translations
  assets/geo/cities/{ISO2}.json      — cities for each country (grouped by country)

Usage:
  python3 tool/sync_geo_data.py
  python3 tool/sync_geo_data.py --ref v2.6        # specific git tag
  python3 tool/sync_geo_data.py --input data.json  # local file (countries+states+cities)
"""

import argparse
import json
import os
import sys
import urllib.request

BASE_URL = "https://raw.githubusercontent.com/dr5hn/countries-states-cities-database/{ref}/json"
COMBINED_FILE = "countries+states+cities.json"
STATES_FILE = "states.json"

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "geo")

SUPPORTED_LOCALES = ["br", "ko", "pt-BR", "pt", "nl", "hr", "fa", "de", "es",
                     "fr", "ja", "it", "zh-CN", "tr", "ru", "uk", "pl", "hi", "ar"]


def download(url: str, label: str) -> bytes:
    print(f"  Downloading {label}...", end=" ", flush=True)
    with urllib.request.urlopen(url) as r:
        data = r.read()
    print(f"{len(data) // 1024} KB")
    return data


def slim_translations(translations) -> dict:
    if not isinstance(translations, dict):
        return {}
    return {k: v for k, v in translations.items() if k in SUPPORTED_LOCALES and v}


def build_countries(combined: list, states_index: dict) -> list:
    countries = []
    for c in combined:
        iso2 = c["iso2"]
        countries.append({
            "id": c["id"],
            "name": c["name"],
            "iso2": iso2,
            "emoji": c.get("emoji", ""),
            "translations": slim_translations(c.get("translations", {})),
        })
    return sorted(countries, key=lambda x: x["name"])


def build_states(states_raw: list) -> dict[str, list]:
    """Returns {ISO2: [state, ...]} with translations, sorted by name."""
    by_country: dict[str, list] = {}
    for s in states_raw:
        iso2 = s["country_code"]
        by_country.setdefault(iso2, []).append({
            "id": s["id"],
            "name": s["name"],
            "iso2": s.get("iso2") or None,
            "type": s.get("type") or None,
            "translations": slim_translations(s.get("translations", {})),
        })
    for iso2 in by_country:
        by_country[iso2].sort(key=lambda x: x["name"])
    return by_country


def build_cities(combined: list) -> dict[str, list]:
    """Returns {ISO2: [city, ...]} sorted by name."""
    by_country: dict[str, list] = {}
    for country in combined:
        iso2 = country["iso2"]
        cities = []
        for state in country.get("states", []):
            state_id = state["id"]
            for city in state.get("cities", []):
                cities.append({
                    "id": city["id"],
                    "name": city["name"],
                    "state_id": state_id,
                })
        if cities:
            cities.sort(key=lambda x: x["name"])
            by_country[iso2] = cities
    return by_country


def write_json(path: str, data) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))


def main():
    parser = argparse.ArgumentParser(description="Sync geo data for Flutter assets")
    parser.add_argument("--ref", default="master", help="Git ref (branch/tag)")
    parser.add_argument("--input", default=None, help="Local countries+states+cities.json")
    args = parser.parse_args()

    print("=== Sora Weather — Geo Data Sync ===\n")

    # --- Load combined data ---
    if args.input:
        print(f"  Loading local file: {args.input}")
        with open(args.input, encoding="utf-8") as f:
            combined = json.load(f)
    else:
        url = f"{BASE_URL.format(ref=args.ref)}/{COMBINED_FILE}"
        combined = json.loads(download(url, COMBINED_FILE))

    # --- Load states with translations ---
    url = f"{BASE_URL.format(ref=args.ref)}/{STATES_FILE}"
    states_raw = json.loads(download(url, STATES_FILE))

    print(f"\n  Loaded: {len(combined)} countries, {len(states_raw)} states")

    # --- Build datasets ---
    print("\n  Building countries...")
    countries = build_countries(combined, states_raw)

    print("  Building states...")
    states_by_country = build_states(states_raw)

    print("  Building cities...")
    cities_by_country = build_cities(combined)

    total_cities = sum(len(v) for v in cities_by_country.values())
    total_states = sum(len(v) for v in states_by_country.values())
    print(f"  → {len(countries)} countries, {total_states} states, {total_cities} cities")

    # --- Write output ---
    print(f"\n  Writing assets to {OUTPUT_DIR}/")

    countries_path = os.path.join(OUTPUT_DIR, "countries.json")
    write_json(countries_path, countries)
    size_kb = os.path.getsize(countries_path) // 1024
    print(f"  ✓ countries.json ({size_kb} KB)")

    states_dir = os.path.join(OUTPUT_DIR, "states")
    total_size = 0
    for iso2, states in states_by_country.items():
        path = os.path.join(states_dir, f"{iso2}.json")
        write_json(path, states)
        total_size += os.path.getsize(path)
    print(f"  ✓ states/{'{'}ISO2{'}'}.json — {len(states_by_country)} files ({total_size // 1024} KB total)")

    cities_dir = os.path.join(OUTPUT_DIR, "cities")
    total_size = 0
    for iso2, cities in cities_by_country.items():
        path = os.path.join(cities_dir, f"{iso2}.json")
        write_json(path, cities)
        total_size += os.path.getsize(path)
    print(f"  ✓ cities/{'{'}ISO2{'}'}.json — {len(cities_by_country)} files ({total_size // 1024} KB total)")

    print("\n=== Done ===")
    print("\nNext: add assets/geo/ to pubspec.yaml flutter.assets")


if __name__ == "__main__":
    main()
