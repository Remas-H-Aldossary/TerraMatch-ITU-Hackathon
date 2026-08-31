# -*- coding: utf-8 -*-
"""
parse_kb_en.py
Parses the English knowledge base (Markdown) into chunks suitable for
vector indexing, with metadata attached to each chunk: category, status
(Active/Repealed), and official source links.
"""
import re
import json

SRC_PATH = "kb_en.md"
OUT_PATH = "kb_chunks_en.json"

CATEGORY_BY_KEYWORDS = [
    ("PDPL", ["PDPL", "Personal Data Protection", "SDAIA", "Privacy"]),
    ("Agricultural Quarantine", ["Quarantine"]),
    ("Pesticides", ["Pesticide"]),
    ("Fertilizers", ["Fertilizer"]),
    ("Organic Agriculture", ["Organic Agriculture", "organic"]),
    ("Agriculture Law", ["Agriculture Law"]),
]


def detect_category(parent: str, title: str, body: str) -> str:
    text = parent + " " + title + " " + body
    for cat, keywords in CATEGORY_BY_KEYWORDS:
        if any(k.lower() in text.lower() for k in keywords):
            return cat
    return "General"


def detect_status(parent: str, body: str) -> str:
    text = parent + " " + body
    if "Repealed" in text:
        return "Repealed"
    if "Active" in text:
        return "Active"
    return "Unspecified"


def extract_links(body: str):
    return re.findall(r"https?://\S+", body)


def split_into_sections(text: str):
    lines = text.split("\n")
    sections = []
    current_title = None
    current_parent = ""
    current_body = []

    heading_re = re.compile(r"^(#{1,3})\s+(.*)$")

    for line in lines:
        m = heading_re.match(line.strip())
        if m:
            if current_title is not None and current_body:
                sections.append(
                    {
                        "parent": current_parent,
                        "title": current_title,
                        "body": "\n".join(current_body).strip(),
                    }
                )
            level = len(m.group(1))
            current_title = m.group(2).strip()
            if level <= 2:
                current_parent = current_title
            current_body = []
        else:
            current_body.append(line)

    if current_title is not None and current_body:
        sections.append(
            {
                "parent": current_parent,
                "title": current_title,
                "body": "\n".join(current_body).strip(),
            }
        )
    return sections


def build_chunks():
    with open(SRC_PATH, "r", encoding="utf-8") as f:
        text = f.read()

    raw_sections = split_into_sections(text)
    chunks = []
    chunk_id = 1

    for sec in raw_sections:
        body = sec["body"]
        if len(body.strip()) < 30:
            continue

        chunk = {
            "id": f"kb_en_{chunk_id:03d}",
            "title": sec["title"],
            "parent_section": sec["parent"],
            "category": detect_category(sec["parent"], sec["title"], body),
            "status": detect_status(sec["parent"], body),
            "sources": extract_links(body),
            "text": f"{sec['parent']} - {sec['title']}\n{body}".strip()
            if sec["parent"] and sec["parent"] != sec["title"]
            else f"{sec['title']}\n{body}".strip(),
        }
        chunks.append(chunk)
        chunk_id += 1

    by_parent = {}
    for c in chunks:
        by_parent.setdefault(c["parent_section"], []).append(c)

    for parent, group in by_parent.items():
        statuses = {c["status"] for c in group if c["status"] != "Unspecified"}
        if len(statuses) == 1:
            resolved = next(iter(statuses))
            for c in group:
                if c["status"] == "Unspecified":
                    c["status"] = resolved

        cats = {c["category"] for c in group if c["category"] != "General"}
        if len(cats) == 1:
            resolved_cat = next(iter(cats))
            for c in group:
                if c["category"] == "General":
                    c["category"] = resolved_cat

    return chunks


if __name__ == "__main__":
    chunks = build_chunks()
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(chunks, f, ensure_ascii=False, indent=2)
    print(f"Extracted {len(chunks)} chunks, saved to {OUT_PATH}")
    for c in chunks[:5]:
        print("-", c["id"], "|", c["category"], "|", c["status"], "|", c["title"])
