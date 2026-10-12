import { db } from "hatchable";

export const access = "admin";
export const methods = ["GET", "POST", "PUT", "DELETE"];

const TYPES = new Set(["page", "news", "program", "teacher", "gallery", "event", "faq", "testimonial", "download"]);
const FIELDS = new Set(["content_type", "slug", "title", "excerpt", "body", "media_url", "status", "sort_order", "payload", "published_at"]);

function clean(body, partial = false) {
  const out = {};
  for (const [key, value] of Object.entries(body || {})) if (FIELDS.has(key)) out[key] = value;
  if (!partial) {
    out.content_type = String(out.content_type || "");
    out.slug = String(out.slug || "").trim();
    out.title = String(out.title || "").trim();
    out.excerpt = String(out.excerpt || "");
    out.body = String(out.body || "");
    out.media_url = String(out.media_url || "");
    out.status = String(out.status || "draft");
    out.sort_order = Number.isInteger(out.sort_order) ? out.sort_order : 0;
    out.payload = out.payload && typeof out.payload === "object" && !Array.isArray(out.payload) ? out.payload : {};
  }
  return out;
}
function validate(row) {
  if (row.content_type !== undefined && !TYPES.has(row.content_type)) return "Jenis konten tidak valid.";
  if (row.slug !== undefined && !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(String(row.slug))) return "Slug hanya boleh berisi huruf kecil, angka, dan tanda hubung.";
  if (row.title !== undefined && (String(row.title).trim().length < 2 || String(row.title).length > 180)) return "Judul harus berisi 2–180 karakter.";
  if (row.status !== undefined && !["draft", "published", "archived"].includes(row.status)) return "Status konten tidak valid.";
  if (row.media_url !== undefined && row.media_url && !/^https:\/\//i.test(row.media_url)) return "URL media harus menggunakan HTTPS.";
  if (row.payload !== undefined && (!row.payload || typeof row.payload !== "object" || Array.isArray(row.payload))) return "Payload harus berupa objek JSON.";
  return null;
}
async function audit(action, id, details = {}) {
  await db.query("INSERT INTO cms_audit_log (actor_label, action, entity_type, entity_id, details) VALUES ($1,$2,$3,$4,$5::jsonb)", ["admin", action, "cms_content", String(id || ""), JSON.stringify(details)]);
}
export default async function (req, res) {
  if (req.method === "GET") {
    const { rows } = await db.query("SELECT * FROM cms_content ORDER BY updated_at DESC LIMIT 200");
    return res.status(200).json({ items: rows, count: rows.length });
  }
  if (req.method === "POST") {
    const row = clean(req.body || {});
    const invalid = validate(row);
    if (invalid) return res.status(400).json({ error: invalid });
    if (row.title.length < 2 || row.title.length > 180 || !row.slug || !TYPES.has(row.content_type)) return res.status(400).json({ error: "Jenis konten, slug, dan judul wajib diisi dengan benar." });
    const { rows } = await db.query(
      "INSERT INTO cms_content (content_type, slug, title, excerpt, body, media_url, status, sort_order, payload, published_at) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9::jsonb,CASE WHEN $7 = 'published' THEN COALESCE($10::timestamptz, now()) ELSE NULL END) RETURNING *",
      [row.content_type, row.slug, row.title, row.excerpt, row.body, row.media_url, row.status, row.sort_order, JSON.stringify(row.payload), row.published_at || null]
    );
    await audit("create", rows[0].id, { content_type: row.content_type, slug: row.slug });
    return res.status(201).json({ item: rows[0] });
  }
  const id = String(req.query?.id || req.body?.id || "");
  if (!/^[0-9a-f-]{36}$/i.test(id)) return res.status(400).json({ error: "ID konten tidak valid." });
  if (req.method === "PUT") {
    const row = clean(req.body || {}, true);
    const invalid = validate(row);
    if (invalid) return res.status(400).json({ error: invalid });
    const keys = Object.keys(row);
    if (!keys.length) return res.status(400).json({ error: "Tidak ada perubahan yang dikirim." });
    const values = [];
    const sets = keys.map((key) => {
      values.push(key === "payload" ? JSON.stringify(row[key]) : row[key]);
      return key + " = $" + values.length + (key === "payload" ? "::jsonb" : "");
    });
    values.push(id);
    const { rows } = await db.query("UPDATE cms_content SET " + sets.join(", ") + ", updated_at = now() WHERE id = $" + values.length + " RETURNING *", values);
    if (!rows.length) return res.status(404).json({ error: "Konten tidak ditemukan." });
    await audit("update", id, { fields: keys });
    return res.status(200).json({ item: rows[0] });
  }
  const { rows } = await db.query("UPDATE cms_content SET status = 'archived', updated_at = now() WHERE id = $1 RETURNING id, status", [id]);
  if (!rows.length) return res.status(404).json({ error: "Konten tidak ditemukan." });
  await audit("archive", id);
  return res.status(200).json({ item: rows[0] });
}