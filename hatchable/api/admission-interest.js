import { db } from "hatchable";

export const access = "public";
export const methods = ["POST"];

export default async function (req, res) {
  const body = req.body || {};
  const guardianName = String(body.guardian_name || "").trim();
  const contact = String(body.contact || "").trim();
  const program = String(body.program || "belum_tentukan").trim();
  const message = String(body.message || "").trim();

  if (guardianName.length < 2 || guardianName.length > 120) {
    return res.status(400).json({ error: "Nama wali wajib diisi (2–120 karakter)." });
  }
  if (contact.length < 5 || contact.length > 180) {
    return res.status(400).json({ error: "Kontak wajib diisi dan harus valid." });
  }
  if (!["KB", "TK", "belum_tentukan"].includes(program)) {
    return res.status(400).json({ error: "Pilihan program tidak valid." });
  }
  if (message.length > 1500) {
    return res.status(400).json({ error: "Pesan terlalu panjang." });
  }

  const { rows } = await db.query(
    "INSERT INTO admission_interest (guardian_name, contact, program, message, status) VALUES ($1, $2, $3, $4, 'new') RETURNING id, created_at",
    [guardianName, contact, program, message]
  );
  return res.status(201).json({
    reference: String(rows[0].id).slice(0, 8).toUpperCase(),
    created_at: rows[0].created_at,
    storage: "temporary_hatchable_database"
  });
}
