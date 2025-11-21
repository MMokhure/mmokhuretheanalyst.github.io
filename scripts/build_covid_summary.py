import csv
import json
from collections import defaultdict
from datetime import datetime
from pathlib import Path


DATA_FILE = Path("data/owid-covid-data.csv")
OUTPUT_FILE = Path("data/covid-data.json")
TARGET_REGIONS = {"World", "Africa", "Botswana"}


def parse_float(value: str) -> float:
    if not value:
        return 0.0
    try:
        return float(value)
    except ValueError:
        return 0.0


def build_summary():
    if not DATA_FILE.exists():
        raise FileNotFoundError(f"Missing dataset: {DATA_FILE}")

    bucket = defaultdict(lambda: {"new_cases": 0.0, "new_deaths": 0.0, "vaccinations": 0.0})

    with DATA_FILE.open(encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            location = row.get("location")
            if location not in TARGET_REGIONS:
                continue

            date_str = row.get("date")
            if not date_str:
                continue

            date = datetime.strptime(date_str, "%Y-%m-%d").date().replace(day=1)
            key = (location, date.isoformat())

            bucket[key]["new_cases"] += parse_float(row.get("new_cases", "0"))
            bucket[key]["new_deaths"] += parse_float(row.get("new_deaths", "0"))
            bucket[key]["vaccinations"] += parse_float(row.get("new_vaccinations", "0"))

    records = []
    for (region, date), metrics in bucket.items():
        records.append(
            {
                "region": region,
                "date": date,
                "new_cases": round(metrics["new_cases"]),
                "new_deaths": round(metrics["new_deaths"]),
                "vaccinations": round(metrics["vaccinations"]),
            }
        )

    records.sort(key=lambda item: (item["region"], item["date"]))

    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_FILE.write_text(json.dumps(records, indent=4))
    print(f"Wrote {len(records)} records to {OUTPUT_FILE}")


if __name__ == "__main__":
    build_summary()

