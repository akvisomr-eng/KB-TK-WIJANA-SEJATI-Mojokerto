-- Converted CMS core for KB/TK WIJANA SEJATI.
-- Additive and idempotent: does not drop or rewrite existing admission_interest data.
CREATE TABLE IF NOT EXISTS cms_content (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content_type text NOT NULL CHECK (content_type IN ('page','news','program','teacher','gallery','event','faq','testimonial','download')),
  slug text NOT NULL,
  title text NOT NULL,
  excerpt text NOT NULL DEFAULT '',
  body text NOT NULL DEFAULT '',
  media_url text NOT NULL DEFAULT '',
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published','archived')),
  sort_order integer NOT NULL DEFAULT 0,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  published_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (content_type, slug)
);
CREATE INDEX IF NOT EXISTS cms_content_public_listing_idx ON cms_content (content_type, status, sort_order, published_at DESC);
CREATE INDEX IF NOT EXISTS cms_content_updated_idx ON cms_content (updated_at DESC);
CREATE TABLE IF NOT EXISTS cms_menu_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  label text NOT NULL,
  href text NOT NULL,
  parent_id uuid REFERENCES cms_menu_items(id) ON DELETE SET NULL,
  sort_order integer NOT NULL DEFAULT 0,
  is_visible boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS cms_menu_items_order_idx ON cms_menu_items (is_visible, sort_order);
CREATE TABLE IF NOT EXISTS cms_site_settings (
  setting_key text PRIMARY KEY,
  setting_value jsonb NOT NULL DEFAULT '{}'::jsonb,
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS cms_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_name text NOT NULL,
  contact text NOT NULL,
  subject text NOT NULL DEFAULT '',
  message text NOT NULL,
  status text NOT NULL DEFAULT 'new' CHECK (status IN ('new','read','replied','closed')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS cms_messages_status_created_idx ON cms_messages (status, created_at DESC);
CREATE TABLE IF NOT EXISTS cms_audit_log (
  id bigserial PRIMARY KEY,
  actor_label text NOT NULL DEFAULT 'admin',
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id text NOT NULL DEFAULT '',
  details jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS cms_audit_log_created_idx ON cms_audit_log (created_at DESC);
