# -*- coding: utf-8 -*-
"""
build_index.py
يبني فهرساً متجهياً (Vector Store) لمقاطع قاعدة المعرفة.

ملاحظة هندسية مهمة:
نماذج التضمين المعروفة (OpenAI text-embedding-3-large، multilingual-e5) تحتاج
اتصال إنترنت لتنزيلها أو استدعاء API. للعرض التوضيحي (Prototype Demo) في الهاكاثون،
هذا السكربت يستخدم TF-IDF (scikit-learn) كبديل عملي يعمل بالكامل دون إنترنت،
وله نفس الفكرة الرياضية: تمثيل كل مقطع كمتجه رقمي، ثم قياس التشابه (cosine similarity)
بين سؤال المستخدم ومتجهات المقاطع لاسترجاع الأقرب دلالياً.

عند توفر مفتاح API حقيقي وقت التسليم، يكفي استبدال دالة vectorize() هنا
باستدعاء نموذج تضمين حقيقي (OpenAI / Cohere / e5) دون تغيير باقي المنطق.
"""
import json
import pickle
from sklearn.feature_extraction.text import TfidfVectorizer

CHUNKS_PATH = "kb_chunks.json"
INDEX_PATH = "kb_index.pkl"

# قائمة كلمات وقف عربية أساسية (تحسين بسيط لجودة الاسترجاع)
ARABIC_STOPWORDS = [
    "من", "إلى", "على", "في", "عن", "أن", "إن", "التي", "الذي", "هذا", "هذه",
    "ذلك", "كان", "أو", "و", "لا", "ما", "قد", "كل", "بين", "عند", "مع",
    "التي", "التى", "ثم", "لكن", "كما", "غير", "أي", "بعض", "حيث",
]


def vectorize_and_build():
    with open(CHUNKS_PATH, "r", encoding="utf-8") as f:
        chunks = json.load(f)

    texts = [c["text"] for c in chunks]

    vectorizer = TfidfVectorizer(
        analyzer="word",
        ngram_range=(1, 2),
        min_df=1,
        stop_words=ARABIC_STOPWORDS,
    )
    matrix = vectorizer.fit_transform(texts)

    with open(INDEX_PATH, "wb") as f:
        pickle.dump(
            {"vectorizer": vectorizer, "matrix": matrix, "chunks": chunks}, f
        )

    print(f"تم بناء الفهرس: {matrix.shape[0]} مقطعاً × {matrix.shape[1]} خاصية (feature)")
    print(f"محفوظ في: {INDEX_PATH}")


if __name__ == "__main__":
    vectorize_and_build()
