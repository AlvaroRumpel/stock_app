-- =============================================================
-- Stock App - Migração 003: Reestruturação para negócio de chopp
-- =============================================================

-- 1. Simplificar customer (remover address e city_id)
ALTER TABLE customer DROP COLUMN IF EXISTS address;
ALTER TABLE customer DROP COLUMN IF EXISTS city_id;

-- 2. Dropar tabela city (não mais necessária)
DROP TABLE IF EXISTS city;

-- 3. Reestruturar product para lotes com quantidades duplas
ALTER TABLE product DROP COLUMN IF EXISTS volume;
ALTER TABLE product RENAME COLUMN available_quantity TO qty_30l;
ALTER TABLE product ADD COLUMN IF NOT EXISTS qty_50l int4;

-- 4. Criar tabela sale
CREATE TABLE IF NOT EXISTS sale (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     uuid        REFERENCES customer(id),
  total_value     numeric     NOT NULL DEFAULT 0,
  price_per_liter numeric,
  pickup_date     timestamptz,
  return_date     timestamptz,
  is_paid         boolean     NOT NULL DEFAULT false,
  status          text        NOT NULL DEFAULT 'pending',
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz,
  deleted_at      timestamptz
);

-- 5. Criar tabela sale_item
CREATE TABLE IF NOT EXISTS sale_item (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id     uuid        NOT NULL REFERENCES sale(id) ON DELETE CASCADE,
  product_id  uuid        REFERENCES product(id),
  quantity    int4        NOT NULL,
  volume      text        NOT NULL,
  unit_price  numeric     NOT NULL,
  created_at  timestamptz NOT NULL DEFAULT now()
);
