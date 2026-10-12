import { db } from "hatchable";
export const access = "public";
export const methods = ["GET"];
const allowedTypes = new Set(["page","news","program","teacher","gallery","event","faq","testimonial","download"]);
export default async function (req, res) {
  const requested = String(req.query?.type || "").trim();
  if (requested && !allowedTypes.has(requested)) return res.status(400).json({ error: "Jenis konten tidak valid." });
  const rawLimit = Number.parseInt(String(req.query?.limit || "12"), 10);
  const limit = Number.isFinite(rawLimit) ? Math.min(Math.max(rawLimit, 1), 50) : 12;
  const sql = requested
    ? "SELECT id, content_type, slug, title, excerpt, body, media_url, payload, published_at, updated_at FROM cms_content WHERE status = 'published' AND content_type = $1 ORDER BY sort_order ASC, published_at DESC NULLS LAST LIMIT $2"
    : "SELECT id, content_type, slug, title, excerpt, body, media_url, payload, published_at, updated_at FROM cms_content WHERE status = 'published' ORDER BY content_type ASC, sort_order ASC, published_at DESC NULLS LAST LIMIT $1";
  const { rows } = await db.query(sql, requested ? [requested, limit] : [limit]);
  return res.status(200).json({ items: rows, count: rows.length });
}