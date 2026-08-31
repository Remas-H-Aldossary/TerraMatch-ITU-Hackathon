# -*- coding: utf-8 -*-
"""
rag_query.py
محرك الاسترجاع (Retriever) الخاص بالشات بوت — يمثّل عقدتي M/P في مخطط Y.3172:
يستقبل سؤال المستخدم، يبحث عن أقرب المقاطع في الفهرس، ويبني إجابة مرجعية
(كل جزء من الإجابة مرفق باسم النظام وحالته ورابطه الرسمي، لتفادي الهلوسة القانونية).
"""
import pickle
from sklearn.metrics.pairwise import cosine_similarity

INDEX_PATH = "kb_index.pkl"

# لو السؤال ما فيه أي كلمة من كلمات "النية التنظيمية/القانونية" هذي،
# نعتبره خارج النطاق بغض النظر عن درجة التشابه — هذا يمنع الأخطاء اللي
# تصير لما سؤال زراعي فني يتشارك كلمة مع نص نظام رسمي (مثال: "سماد"
# موجودة بنظام الأسمدة وبسؤال "أي سماد أفضل للطماطم؟" رغم اختلاف النية).
REGULATORY_KEYWORDS = [
    "نظام", "لائحة", "قانون", "مرسوم", "PDPL", "بيانات شخصية", "حماية البيانات",
    "نقل البيانات", "نقل", "بيانات", "تسجيل", "ترخيص", "رخصة", "مسؤول", "سياسة",
    "غرامة", "عقوبة", "عقوبات", "مخالفة", "انتهاك", "متطلب", "متطلبات", "امتثال",
    "الإفصاح", "إفصاح", "موافقة", "معالجة البيانات", "مادة", "هيئة", "وزارة",
    "سدايا", "MEWA", "قانوني", "قانونية", "حجر زراعي", "ساري", "ملغى",
    "سجن", "غرامة مالية", "خصوصية", "المملكة",
]


def _is_regulatory_question(question: str) -> bool:
    return any(k in question for k in REGULATORY_KEYWORDS)


def load_index():
    with open(INDEX_PATH, "rb") as f:
        return pickle.load(f)


def retrieve(question: str, index, top_k: int = 3):
    vectorizer = index["vectorizer"]
    matrix = index["matrix"]
    chunks = index["chunks"]

    q_vec = vectorizer.transform([question])
    scores = cosine_similarity(q_vec, matrix).flatten()
    ranked = scores.argsort()[::-1][:top_k]

    results = []
    for i in ranked:
        if scores[i] <= 0:
            continue
        c = chunks[i]
        results.append({**c, "score": round(float(scores[i]), 4)})
    return results


def answer(question: str, index, top_k: int = 3, min_score: float = 0.15):
    """
    min_score: الحد الأدنى لدرجة التشابه لاعتبار المقطع "إجابة حقيقية".
    أي تطابق أضعف من هذا الرقم يعني السؤال خارج نطاق قاعدة المعرفة
    (غالباً سؤال زراعي/فني يخص نموذج CS1، مو نظام/لائحة).
    """
    results = retrieve(question, index, top_k)
    results = [r for r in results if r["score"] >= min_score]

    if not results or not _is_regulatory_question(question):
        return {
            "question": question,
            "answer": "هذا السؤال يبدو خارج نطاق قاعدة الأنظمة واللوائح المتوفرة لدي "
            "(أنا متخصص في الأنظمة الزراعية ونظام حماية البيانات PDPL فقط، "
            "وليس تحليل التربة أو تشخيص أمراض النبات أو توصيات المبيدات). "
            "لو سؤالك عن نظام أو لائحة رسمية، حاولي صياغته بشكل أوضح (مثال: "
            "'هل يجوز نقل بيانات المزارع خارج المملكة؟').",
            "top_sources": "",
            "sources": [],
            "in_scope": False,
        }

    lines = []
    for r in results:
        status_flag = f"⚠️ حالة النظام: {r['status']}" if r["status"] == "ملغى" else f"الحالة: {r['status']}"
        lines.append(f"— [{r['category']}] {r['title']} ({status_flag})")

    citation_block = "\n".join(lines)
    top = results[0]

    return {
        "question": question,
        "answer": f"بحسب قاعدة المعرفة الرسمية، أقرب مرجع لسؤالك هو: «{top['title']}» "
        f"ضمن تصنيف [{top['category']}]، وحالته: {top['status']}. "
        f"(هذا ليس استشارة قانونية — يُنصح بمراجعة النص الرسمي الكامل عند الحاجة لتوثيق قانوني).",
        "top_sources": citation_block,
        "sources": [{"title": r["title"], "links": r["sources"]} for r in results if r["sources"]],
        "in_scope": True,
    }


if __name__ == "__main__":
    idx = load_index()

    test_questions = [
        "هل نظام الزراعة العضوية القديم لا يزال سارياً؟",
        "كم مدة الرد على طلبات أصحاب البيانات بموجب PDPL؟",
        "هل يمكن نقل بيانات المزارعين خارج المملكة؟",
        "ما العقوبة على الإفصاح غير المصرح به عن بيانات شخصية حساسة؟",
        "هل يوجد تسجيل مطلوب للمبيدات الزراعية؟",
    ]

    for q in test_questions:
        result = answer(q, idx, top_k=2)
        print("=" * 70)
        print("السؤال:", result["question"])
        print("الإجابة:", result["answer"])
        print("أقرب المصادر:\n", result.get("top_sources", ""))
