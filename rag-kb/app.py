# -*- coding: utf-8 -*-
"""
app.py
Unified FastAPI service for the Knowledge Base RAG engine.
Bilingual: automatically detects whether the incoming question is in
Arabic or English, and answers using the matching knowledge base and
language — a single endpoint for the Dev/mobile app team to call,
regardless of which language the farmer types in.

Run locally:
    uvicorn app:app --reload --port 8000

Test at:
    http://localhost:8000/docs
"""
import re
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

import rag_query as rag_ar
import rag_query_en as rag_en

app = FastAPI(
    title="TerraMatch Knowledge Base API",
    description="Bilingual (Arabic/English) retrieval service for Saudi agricultural "
    "regulations and the Personal Data Protection Law (PDPL) — represents nodes M/P "
    "in the ITU-T Y.3172 pipeline.",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Both indices load once at startup, not per-request (much faster).
INDEX_AR = rag_ar.load_index()
INDEX_EN = rag_en.load_index()

ARABIC_CHARS = re.compile(r"[\u0600-\u06FF]")


def detect_language(text: str) -> str:
    """Returns 'ar' if the text contains Arabic script, else 'en'."""
    return "ar" if ARABIC_CHARS.search(text) else "en"


class QuestionRequest(BaseModel):
    question: str
    top_k: int = 3
    # Optional override: force "ar" or "en" instead of auto-detecting.
    language: str | None = None


class SourceItem(BaseModel):
    title: str
    links: list[str]


class AnswerResponse(BaseModel):
    question: str
    answer: str
    top_sources: str
    sources: list[SourceItem]
    in_scope: bool
    detected_language: str


@app.get("/")
def health_check():
    """Simple health check to confirm the server is running after deployment."""
    return {"status": "ok", "service": "TerraMatch Knowledge Base API (bilingual AR/EN)"}


@app.post("/ask", response_model=AnswerResponse)
def ask(request: QuestionRequest):
    """
    Main endpoint: accepts a question in Arabic or English, returns a
    grounded answer in the same language, citing the matching official
    regulation and its status (in force / repealed).

    Example request body (Arabic):
    {"question": "هل يمكن نقل بيانات المزارعين خارج المملكة؟", "top_k": 3}

    Example request body (English):
    {"question": "Can farmer data be transferred outside the Kingdom?", "top_k": 3}

    Note for the app team: this endpoint only answers regulatory/legal
    questions (Saudi agricultural laws + PDPL). Agronomy questions (soil
    analysis, disease diagnosis, pesticide dosage) should be routed to
    CS1's ML model instead — check the "in_scope" field in the response
    to detect when a question falls outside this API's domain.
    """
    if not request.question.strip():
        raise HTTPException(status_code=400, detail="Question is empty / السؤال فارغ")

    lang = request.language if request.language in ("ar", "en") else detect_language(request.question)

    if lang == "ar":
        result = rag_ar.answer(request.question, INDEX_AR, top_k=request.top_k)
    else:
        result = rag_en.answer(request.question, INDEX_EN, top_k=request.top_k)

    return {
        "question": result["question"],
        "answer": result["answer"],
        "top_sources": result.get("top_sources", ""),
        "sources": result.get("sources", []),
        "in_scope": result.get("in_scope", False),
        "detected_language": lang,
    }
