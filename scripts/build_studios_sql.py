#!/usr/bin/env python3
"""'개발용' 시트 CSV -> Supabase INSERT SQL 생성기.

room_{name,price,capacity,max_capacity,equipment}_1..10 의 와이드 포맷을
rooms jsonb 배열로 접는다. rooms 외의 컬럼은 원본 그대로 통과시킨다.

사용법:
    python3 scripts/build_studios_sql.py dev.csv > supabase/seed/dev_studios.sql
"""

import csv
import json
import re
import sys

MAX_ROOMS = 10

# equipment 셀 안에서 악기 카테고리 헤더로 쓰이는 줄
EQUIPMENT_CATEGORIES = {
    "드럼", "기타", "베이스", "키보드", "건반",
    "마이크", "앰프", "피아노", "신디",
}

# 장비 없음을 뜻하는 센티넬
NO_EQUIPMENT = "등록된 장비 정보가 없습니다."

PASSTHROUGH = [
    "studio_name",
    "region",
    "studio_phone",
    "reservation_method",
    "reservation_method_link",
    "studio_photo",
    "address",
]

COLUMNS = PASSTHROUGH[:2] + ["rooms"] + PASSTHROUGH[2:]


def parse_price(raw):
    """'22,000원' -> 22000. 숫자가 없으면 None."""
    if not raw:
        return None
    digits = re.sub(r"[^\d]", "", raw)
    return int(digits) if digits else None


def parse_capacity(raw):
    """'10.0' / '10' -> 10. 숫자가 아니면 None."""
    if not raw:
        return None
    try:
        return int(float(raw))
    except ValueError:
        return None


def parse_equipments(raw, anomalies, studio, room_no):
    """줄바꿈으로 구분된 장비 문자열을 [{type, models}] 로 접는다.

    카테고리 줄이 나오면 새 그룹을 열고, 그 아래 줄들은 모델로 쌓인다.
    """
    if not raw:
        return []

    lines = [ln.strip() for ln in raw.split("\n") if ln.strip()]
    if not lines or lines[0] == NO_EQUIPMENT:
        return []

    groups = []
    current = None
    for line in lines:
        if line in EQUIPMENT_CATEGORIES:
            current = {"type": line, "models": []}
            groups.append(current)
        elif current is None:
            # 카테고리 없이 시작 -> 장비 컬럼에 다른 데이터가 섞인 경우
            anomalies.append(
                f"{studio} room#{room_no}: 장비 컬럼에 비장비 값 -> {line!r}"
            )
            return []
        else:
            current["models"].append(line)

    return [g for g in groups if g["models"]]


def build_rooms(row, idx, anomalies):
    rooms = []
    studio = row[idx["studio_name"]]

    for n in range(1, MAX_ROOMS + 1):
        name = row[idx[f"room_name_{n}"]].strip()
        price_raw = row[idx[f"room_price_{n}"]]
        equip_raw = row[idx[f"room_equipment_{n}"]]

        # 이름도 가격도 장비도 없으면 그 슬롯은 비어 있는 것
        if not (name or price_raw or equip_raw):
            continue

        if not name:
            anomalies.append(f"{studio} room#{n}: room_name 비어 있음")

        price = parse_price(price_raw)
        if price_raw and price is None:
            anomalies.append(
                f"{studio} room#{n}: 가격 파싱 실패 -> {price_raw!r}"
            )

        rooms.append({
            "name": name or None,
            "price": price,
            "capacity": parse_capacity(row[idx[f"room_capacity_{n}"]]),
            "max_capacity": parse_capacity(row[idx[f"room_max_capacity_{n}"]]),
            "equipments": parse_equipments(equip_raw, anomalies, studio, n),
        })

    return rooms


def sql_literal(value):
    """문자열을 SQL 리터럴로. 빈 값은 null."""
    if value is None or value == "":
        return "null"
    return "'" + str(value).replace("'", "''") + "'"


def main():
    src = sys.argv[1] if len(sys.argv) > 1 else "dev.csv"
    with open(src, newline="", encoding="utf-8") as f:
        rows = list(csv.reader(f))

    header, data = rows[0], rows[1:]
    idx = {h: i for i, h in enumerate(header)}

    anomalies = []
    values = []
    skipped = []

    for row in data:
        studio = row[idx["studio_name"]].strip()
        if not studio:
            continue

        rooms = build_rooms(row, idx, anomalies)
        if not rooms:
            skipped.append(studio)

        cells = [
            sql_literal(studio),
            sql_literal(row[idx["region"]]),
            sql_literal(json.dumps(rooms, ensure_ascii=False)) + "::jsonb",
        ] + [sql_literal(row[idx[c]]) for c in PASSTHROUGH[2:]]

        values.append("  (" + ", ".join(cells) + ")")

    out = sys.stdout
    out.write("-- '개발용' 시트 -> studios 적재\n")
    out.write(f"-- 스튜디오 {len(values)}개 / 룸 없는 스튜디오 {len(skipped)}개\n\n")
    out.write("create table if not exists studios (\n")
    out.write("  id uuid primary key default gen_random_uuid(),\n")
    out.write("  studio_name text not null,\n")
    out.write("  region text,\n")
    out.write("  rooms jsonb not null default '[]'::jsonb,\n")
    out.write("  studio_phone text,\n")
    out.write("  reservation_method text,\n")
    out.write("  reservation_method_link text,\n")
    out.write("  studio_photo text,\n")
    out.write("  address text,\n")
    out.write("  created_at timestamptz not null default now()\n")
    out.write(");\n\n")
    out.write("insert into studios\n  (" + ", ".join(COLUMNS) + ")\nvalues\n")
    out.write(",\n".join(values))
    out.write(";\n")

    # 리포트는 stderr 로 분리해서 SQL 파일을 오염시키지 않는다
    if skipped:
        print(f"\n[룸 0개] {len(skipped)}개", file=sys.stderr)
        for s in skipped:
            print(f"  - {s}", file=sys.stderr)
    if anomalies:
        print(f"\n[이상값] {len(anomalies)}건", file=sys.stderr)
        for a in anomalies:
            print(f"  - {a}", file=sys.stderr)


if __name__ == "__main__":
    main()
