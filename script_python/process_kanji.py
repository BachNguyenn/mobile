import json
import os
import xml.etree.ElementTree as ET
from datetime import datetime, timezone


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(BASE_DIR)
KANJIDIC_PATH = os.path.join(BASE_DIR, "kanjidic2.xml")
KANJIVG_DIR = os.path.join(BASE_DIR, "kanji")
OUTPUT_DIR = os.path.join(PROJECT_DIR, "assets", "data")
SOURCE_MANIFEST_PATH = os.path.join(OUTPUT_DIR, "kanji_sources_manifest.json")


def repair_mojibake(value):
    if value is None:
        return None
    if not isinstance(value, str):
        return value
    markers = ("Ã", "ã", "ä", "å", "æ", "ç", "è", "é", "ê", "ì")
    if not any(marker in value for marker in markers):
        return value
    try:
        return value.encode("latin1").decode("utf-8")
    except UnicodeError:
        return value


def as_int(value):
    if value is None:
        return None
    try:
        return int(value)
    except (TypeError, ValueError):
        return None


def get_ucs_hex(character):
    cp_value = character.find("./codepoint/cp_value[@cp_type='ucs']")
    if cp_value is not None and cp_value.text:
        return cp_value.text.strip().lower().zfill(5)
    literal = repair_mojibake(character.findtext("literal", ""))
    return f"{ord(literal):05x}" if literal else ""


def get_literal(character):
    ucs_hex = get_ucs_hex(character)
    if ucs_hex:
        return chr(int(ucs_hex, 16))
    return repair_mojibake(character.findtext("literal", ""))


def text_list(elements):
    return [
        repaired
        for repaired in (repair_mojibake(element.text) for element in elements)
        if repaired
    ]


def parse_svg_paths(file_path):
    if not os.path.exists(file_path):
        return []
    try:
        tree = ET.parse(file_path)
        root = tree.getroot()
        paths = []
        for path in root.findall(".//{http://www.w3.org/2000/svg}path"):
            path_data = path.get("d")
            if path_data:
                paths.append(path_data)
        return paths
    except ET.ParseError:
        return []


def first_int(character, path):
    return as_int(character.findtext(path))


def parse_radicals(character):
    radical_values = {}
    for element in character.findall("./radical/rad_value"):
        radical_type = element.get("rad_type", "unknown")
        value = as_int(element.text)
        if value is not None:
            radical_values[radical_type] = value
    return radical_values


def parse_variants(character):
    variants = []
    for element in character.findall("./misc/variant"):
        variant_type = element.get("var_type", "unknown")
        value = repair_mojibake(element.text)
        if value:
            variants.append(f"{variant_type}: {value}")
    return variants


def parse_query_codes(character):
    query_codes = []
    for element in character.findall("./query_code/q_code"):
        query_type = element.get("qc_type", "unknown")
        value = repair_mojibake(element.text)
        if value:
            query_codes.append(f"{query_type}: {value}")
    return query_codes


def map_jlpt_level(old_level, total_chars):
    if old_level == 4:
        return 5
    if old_level == 3:
        return 4
    if old_level == 2:
        return 3 if total_chars % 2 == 0 else 2
    if old_level == 1:
        return 1
    return old_level


def build_entry(character, level, total_chars):
    literal = get_literal(character)
    unicode_hex = get_ucs_hex(character)
    svg_file = os.path.join(KANJIVG_DIR, f"{unicode_hex}.svg")
    stroke_paths = parse_svg_paths(svg_file)
    radical_values = parse_radicals(character)

    meanings = text_list(
        element
        for element in character.findall(".//reading_meaning/rmgroup/meaning")
        if element.get("m_lang") is None
    )
    on_readings = text_list(
        element
        for element in character.findall(".//reading_meaning/rmgroup/reading")
        if element.get("r_type") == "ja_on"
    )
    kun_readings = text_list(
        element
        for element in character.findall(".//reading_meaning/rmgroup/reading")
        if element.get("r_type") == "ja_kun"
    )

    stroke_count = first_int(character, "./misc/stroke_count")
    if stroke_count is None and stroke_paths:
        stroke_count = len(stroke_paths)

    return {
        "id": unicode_hex,
        "character": literal,
        "meanings": meanings,
        "on_reading": on_readings,
        "kun_reading": kun_readings,
        "stroke_data": stroke_paths,
        "stroke_paths": stroke_paths,
        "stroke_count": stroke_count,
        "grade": first_int(character, "./misc/grade"),
        "frequency": first_int(character, "./misc/freq"),
        "radical_number": radical_values.get("classical"),
        "radical_names": text_list(character.findall("./misc/rad_name")),
        "radical_values": [
            f"{radical_type}: {value}"
            for radical_type, value in sorted(radical_values.items())
        ],
        "nanori": text_list(character.findall(".//reading_meaning/nanori")),
        "variants": parse_variants(character),
        "query_codes": parse_query_codes(character),
        "jlpt_level": level,
        "source_refs": ["KANJIDIC2", "KanjiVG"] if stroke_paths else ["KANJIDIC2"],
        "source_order": total_chars,
    }


def write_source_manifest(counts):
    manifest = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "sources": [
            {
                "name": "KANJIDIC2",
                "role": "Kanji meanings, readings, radicals, stroke counts, grade, frequency, variants, query codes.",
                "runtime_asset": False,
            },
            {
                "name": "KanjiVG",
                "role": "SVG stroke paths normalized into compact stroke path arrays.",
                "license": "Creative Commons Attribution-Share Alike 3.0",
                "url": "http://kanjivg.tagaini.net",
                "runtime_asset": False,
            },
        ],
        "output": {
            "runtime_assets": [
                "assets/data/n1/kanji.json",
                "assets/data/n2/kanji.json",
                "assets/data/n3/kanji.json",
                "assets/data/n4/kanji.json",
                "assets/data/n5/kanji.json",
            ],
            "raw_xml_svg_bundled": False,
            "level_counts": counts,
        },
    }
    with open(SOURCE_MANIFEST_PATH, "w", encoding="utf-8", newline="\n") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)
        f.write("\n")


def main():
    if not os.path.exists(KANJIDIC_PATH):
        print(f"Missing KANJIDIC2 file: {KANJIDIC_PATH}")
        return
    if not os.path.exists(KANJIVG_DIR):
        print(f"Missing KanjiVG SVG directory: {KANJIVG_DIR}")
        return

    tree = ET.parse(KANJIDIC_PATH)
    root = tree.getroot()

    levels_data = {i: [] for i in range(1, 6)}
    total_chars = 0
    no_jlpt_count = 0
    no_svg_count = 0

    print("Scanning KANJIDIC2 and KanjiVG sources...")

    for character in root.findall("character"):
        total_chars += 1
        jlpt_elem = character.find(".//misc/jlpt")
        if jlpt_elem is None:
            no_jlpt_count += 1
            continue

        level = map_jlpt_level(int(jlpt_elem.text), total_chars)
        entry = build_entry(character, level, total_chars)
        if not entry["stroke_paths"]:
            no_svg_count += 1
        levels_data[level].append(entry)

    counts = {}
    for level, data in levels_data.items():
        if not data:
            continue
        level_folder = os.path.join(OUTPUT_DIR, f"n{level}")
        os.makedirs(level_folder, exist_ok=True)
        data.sort(key=lambda item: item["source_order"])
        for item in data:
            item.pop("source_order", None)
        with open(
            os.path.join(level_folder, "kanji.json"),
            "w",
            encoding="utf-8",
            newline="\n",
        ) as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
        counts[f"n{level}"] = len(data)
        print(f"N{level}: wrote {len(data)} kanji.")

    write_source_manifest(counts)

    print("\nSummary")
    print(f"Total XML characters: {total_chars}")
    print(f"Characters without JLPT tag: {no_jlpt_count}")
    print(f"JLPT characters without KanjiVG paths: {no_svg_count}")
    print(f"Source manifest: {SOURCE_MANIFEST_PATH}")


if __name__ == "__main__":
    main()
