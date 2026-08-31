# -*- coding: utf-8 -*-
"""
rag_query_en.py
English version of the retrieval engine — represents nodes M/P in the
Y.3172 pipeline. Includes the same minimum-confidence threshold as the
Arabic version, so out-of-scope agronomy questions (soil, disease,
pesticide dosage) are correctly flagged instead of forcing an irrelevant
regulatory match.
"""
import pickle
from sklearn.metrics.pairwise import cosine_similarity

INDEX_PATH = "kb_index_en.pkl"

# If a question contains none of these regulatory/legal-intent keywords,
# it is treated as out of scope regardless of similarity score. This
# guards against false positives where an agronomy question happens to
# share vocabulary with a law's title (e.g. "fertilizer" or "soil"
# appearing in both a farming question and the Fertilizers Law text).
REGULATORY_KEYWORDS = [
    "law", "regulation", "regulations", "pdpl", "personal data", "data protection",
    "transfer", "register", "registration", "officer", "policy", "penalty",
    "penalties", "violation", "permit", "license", "licence", "requirement",
    "requirements", "comply", "compliance", "rule", "rules", "act", "decree",
    "executive regulation", "disclosure", "consent", "provision", "article",
    "authority", "ministry", "mewa", "sdaia", "legal", "quarantine", "in force",
    "repealed", "sanction", "fine", "imprisonment",
]


def _is_regulatory_question(question: str) -> bool:
    q = question.lower()
    return any(k in q for k in REGULATORY_KEYWORDS)


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
    min_score: minimum similarity score to treat a chunk as a genuine match.
    Anything below this means the question is out of scope for this
    regulatory knowledge base (likely an agronomy question that belongs
    to CS1's ML model, not a law/regulation question).
    """
    results = retrieve(question, index, top_k)
    results = [r for r in results if r["score"] >= min_score]

    if not results or not _is_regulatory_question(question):
        return {
            "question": question,
            "answer": "This question appears to be outside the scope of the regulations "
            "knowledge base available to me (I specialize only in Saudi agricultural "
            "regulations and the Personal Data Protection Law - PDPL, not soil analysis, "
            "plant disease diagnosis, or pesticide dosage recommendations). "
            "If your question is about a specific law or regulation, try rephrasing it "
            "more explicitly (example: 'Can farmer data be transferred outside the Kingdom?').",
            "top_sources": "",
            "sources": [],
            "in_scope": False,
        }

    lines = []
    for r in results:
        status_flag = f"⚠️ Status: {r['status']}" if r["status"] == "Repealed" else f"Status: {r['status']}"
        lines.append(f"— [{r['category']}] {r['title']} ({status_flag})")

    citation_block = "\n".join(lines)
    top = results[0]

    return {
        "question": question,
        "answer": f"According to the official knowledge base, the closest reference to your "
        f"question is: \"{top['title']}\" under the [{top['category']}] category, "
        f"status: {top['status']}. "
        f"(This is not legal advice — please refer to the full official text for legal documentation).",
        "top_sources": citation_block,
        "sources": [{"title": r["title"], "links": r["sources"]} for r in results if r["sources"]],
        "in_scope": True,
    }


if __name__ == "__main__":
    idx = load_index()

    test_questions = [
        "Is the old organic agriculture law still in force?",
        "How long does a controller have to respond to a data subject request under PDPL?",
        "Can farmer data be transferred outside the Kingdom?",
        "What is the penalty for unauthorized disclosure of sensitive personal data?",
        "Is registration required for agricultural pesticides?",
        "What is the ideal soil pH for wild berries?",
    ]

    for q in test_questions:
        result = answer(q, idx, top_k=2)
        print("=" * 70)
        print("Q:", result["question"])
        print("in_scope:", result["in_scope"])
        print("A:", result["answer"])
        print("Top sources:\n", result.get("top_sources", ""))
