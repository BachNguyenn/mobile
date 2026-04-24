import os
import json
import xml.etree.ElementTree as ET

# --- CẤU HÌNH ---
KANJIDIC_PATH = 'kanjidic2.xml'
KANJIVG_DIR = 'kanji' 
OUTPUT_DIR = 'assets/data'

def get_unicode_hex(char):
    return "{:05x}".format(ord(char))

def parse_svg_paths(file_path):
    if not os.path.exists(file_path):
        return None
    try:
        tree = ET.parse(file_path)
        root = tree.getroot()
        paths = []
        for path in root.findall(".//{http://www.w3.org/2000/svg}path"):
            d = path.get('d')
            if d: paths.append(d)
        return paths
    except:
        return None

def main():
    if not os.path.exists(KANJIDIC_PATH):
        print(f"❌ KHÔNG TÌM THẤY FILE: {KANJIDIC_PATH}")
        return
    if not os.path.exists(KANJIVG_DIR):
        print(f"❌ KHÔNG TÌM THẤY THƯ MỤC SVG: {KANJIVG_DIR}")
        return

    tree = ET.parse(KANJIDIC_PATH)
    root = tree.getroot()

    levels_data = {i: [] for i in range(1, 6)}
    total_chars = 0
    no_jlpt_count = 0
    no_svg_count = 0

    print("--- ĐANG QUÉT DỮ LIỆU ---")

    for character in root.findall('character'):
        total_chars += 1
        literal = character.find('literal').text
        
        # Kiểm tra thẻ JLPT
        jlpt_elem = character.find('.//misc/jlpt')
        if jlpt_elem is None:
            no_jlpt_count += 1
            continue
        
        old_level = int(jlpt_elem.text)
        
        # Ánh xạ JLPT cũ (1,2,3,4) sang JLPT mới (N1, N2, N3, N4, N5)
        if old_level == 4:
            level = 5
        elif old_level == 3:
            level = 4
        elif old_level == 2:
            # Tách JLPT 2 cũ (739 chữ) thành N3 và N2
            level = 3 if total_chars % 2 == 0 else 2
        elif old_level == 1:
            level = 1
        else:
            level = old_level
        
        # Thử tìm file SVG
        unicode_hex = get_unicode_hex(literal)
        svg_file = os.path.join(KANJIVG_DIR, f"{unicode_hex}.svg")
        
        stroke_data = parse_svg_paths(svg_file)

        if not stroke_data:
            if level == 5:
                print(f"⚠️ N5: Chữ '{literal}' ({unicode_hex}) thiếu file SVG tại {svg_file}")
            no_svg_count += 1
            continue

        # Lấy thông tin khác
        meanings = [m.text for m in character.findall(".//reading_meaning/rmgroup/meaning") if m.get('m_lang') is None]
        on_readings = [r.text for r in character.findall(".//reading_meaning/rmgroup/reading") if r.get('r_type') == 'ja_on']
        kun_readings = [r.text for r in character.findall(".//reading_meaning/rmgroup/reading") if r.get('r_type') == 'ja_kun']

        levels_data[level].append({
            "id": unicode_hex,
            "character": literal,
            "meanings": meanings,
            "on_reading": on_readings,
            "kun_reading": kun_readings,
            "stroke_data": stroke_data,
            "jlpt_level": level
        })

    # Xuất file
    for level, data in levels_data.items():
        if data:
            level_folder = os.path.join(OUTPUT_DIR, f"n{level}")
            os.makedirs(level_folder, exist_ok=True)
            with open(os.path.join(level_folder, 'kanji.json'), 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"✅ N{level}: Đã xuất {len(data)} chữ.")

    print("\n--- BÁO CÁO THỐNG KÊ ---")
    print(f"Tổng số chữ trong XML: {total_chars}")
    print(f"Số chữ không có thẻ <jlpt>: {no_jlpt_count}")
    print(f"Số chữ có JLPT nhưng thiếu SVG: {no_svg_count}")

if __name__ == "__main__":
    main()