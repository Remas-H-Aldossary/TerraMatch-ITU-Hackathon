# CS2 Deliverable — Knowledge Base / RAG (Bilingual AR/EN)

## 🔗 Live service (needs redeployment with the updated files below)
```
https://terramatch-knowledge-base.onrender.com
```
- **Endpoint:** `POST /ask`
- **Docs:** `/docs`
- ⚠️ First request after idle time may take up to 50s (Render free tier)

## What changed in this version
1. **Bilingual support (Arabic + English):** the API now auto-detects the
   question's language and answers in the same language, using the
   matching knowledge base (`kb.md` for Arabic, `kb_en.md` for English).
2. **Scope guard fix:** previously the engine would force an answer even
   for agronomy questions (soil pH, disease diagnosis, pesticide dosage)
   that are outside its domain. It now returns `"in_scope": false` and a
   clear message for those, instead of citing an unrelated regulation.
   Agronomy questions should be routed to CS1's ML model instead.

## Files
| File | Description |
|---|---|
| `kb.md` / `kb_en.md` | Source knowledge base (Arabic original / English translation) |
| `parse_kb.py` / `parse_kb_en.py` | Chunk the source file into indexed pieces with metadata |
| `kb_chunks.json` / `kb_chunks_en.json` | Parsed chunks (56 each) |
| `build_index.py` | Builds the TF-IDF vector index (run once per language) |
| `kb_index.pkl` / `kb_index_en.pkl` | Ready-to-use indices (no need to rebuild) |
| `rag_query.py` / `rag_query_en.py` | Retrieval engine per language, with scope-guard logic |
| `app.py` | **Unified bilingual FastAPI service** — single endpoint for both languages |
| `requirements.txt`, `Procfile` | Deployment files for Render (or similar) |
| `Regulations_List_EN.md` / `قائمة_الأنظمة_واللوائح.md` | Regulation list for the report (EN/AR) |

## Redeploying the update
The already-live Render service is running the **old** single-language
`app.py`. To deploy this bilingual version:
1. Replace `app.py`, add `rag_query_en.py`, `kb_index_en.pkl`, `kb_chunks_en.json`
   in the same GitHub repo used before.
2. Commit and push — Render auto-redeploys within a few minutes.
3. Test both languages via `/docs` before notifying the Dev team.

## API usage examples

**Arabic:**
```json
{"question": "هل يمكن نقل بيانات المزارعين خارج المملكة؟", "top_k": 3}
```

**English:**
```json
{"question": "Can farmer data be transferred outside the Kingdom?", "top_k": 3}
```

**Response fields:** `answer`, `top_sources`, `sources`, `in_scope` (true/false),
`detected_language` ("ar"/"en").
