# -*- coding: utf-8 -*-
"""
parse_kb.py
يقرأ ملف قاعدة المعرفة (Markdown) ويقسمه إلى مقاطع (chunks) صالحة للفهرسة في Vector DB،
مع إرفاق ميتاداتا لكل مقطع: اسم القسم، الحالة (ساري/ملغى)، التصنيف، والروابط الرسمية.
"""
import re
import json

SRC_PATH = "kb.md"
OUT_PATH = "kb_chunks.json"

CATEGORY_BY_KEYWORDS = [
    ("PDPL", ["PDPL", "حماية البيانات", "سدايا", "خصوصية"]),
    ("الحجر الزراعي", ["الحجر الزراعي"]),
    ("المبيدات", ["المبيدات"]),
    ("الأسمدة", ["الأسمدة"]),
    ("الزراعة العضوية", ["الزراعة العضوية", "عضوية"]),
    ("نظام الزراعة", ["نظام الزراعة", "اللائحة التنفيذية لنظام الزراعة"]),
]


def detect_category(parent: str, title: str, body: str) -> str:
    text = parent + " " + title + " " + body
    for cat, keywords in CATEGORY_BY_KEYWORDS:
        if any(k in text for k in keywords):
            return cat
    return "عام"


def detect_status(parent: str, body: str) -> str:
    text = parent + " " + body
    if "ملغى" in text:
        return "ملغى"
    if "ساري" in text:
        return "ساري"
    return "غير محدد"


def extract_links(body: str):
    return re.findall(r"https?://\S+", body)


def extract_article(title: str, body: str):
    m = re.search(r"المادة\s+[\u0600-\u06FF\s]+", title + " " + body)
    return m.group(0).strip() if m else None


def split_into_sections(text: str):
    """
    يقسم النص حسب عناوين Markdown (# أو ## أو ###) مع الحفاظ على تسلسل
    العنوان الأعلى (parent heading) كسياق لكل قسم فرعي.
    """
    lines = text.split("\n")
    sections = []
    current_title = None
    current_parent = ""
    current_body = []

    heading_re = re.compile(r"^(#{1,3})\s+(.*)$")

    for line in lines:
        m = heading_re.match(line.strip())
        if m:
            # أغلقي القسم السابق
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
            # قسم شبه فارغ (عناوين فرعية بلا محتوى مستقل) - تجاهليه
            continue

        chunk = {
            "id": f"kb_{chunk_id:03d}",
            "title": sec["title"],
            "parent_section": sec["parent"],
            "category": detect_category(sec["parent"], sec["title"], body),
            "status": detect_status(sec["parent"], body),
            "article": extract_article(sec["title"], body),
            "sources": extract_links(body),
            "text": f"{sec['parent']} - {sec['title']}\n{body}".strip()
            if sec["parent"] and sec["parent"] != sec["title"]
            else f"{sec['title']}\n{body}".strip(),
        }
        chunks.append(chunk)
        chunk_id += 1

    # تمرير ثانٍ: نشر حالة (ساري/ملغى) الأقوى المكتشفة داخل نفس القسم الأب
    # على كل مقاطعه الفرعية التي لم تُحدَّد حالتها مباشرة
    by_parent = {}
    for c in chunks:
        by_parent.setdefault(c["parent_section"], []).append(c)

    for parent, group in by_parent.items():
        statuses = {c["status"] for c in group if c["status"] != "غير محدد"}
        if len(statuses) == 1:
            resolved = next(iter(statuses))
            for c in group:
                if c["status"] == "غير محدد":
                    c["status"] = resolved

        cats = {c["category"] for c in group if c["category"] != "عام"}
        if len(cats) == 1:
            resolved_cat = next(iter(cats))
            for c in group:
                if c["category"] == "عام":
                    c["category"] = resolved_cat

    return chunks


if __name__ == "__main__":
    chunks = build_chunks()
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(chunks, f, ensure_ascii=False, indent=2)
    print(f"تم استخراج {len(chunks)} مقطعاً وحفظها في {OUT_PATH}")
    for c in chunks[:5]:
        print("-", c["id"], "|", c["category"], "|", c["status"], "|", c["title"])
