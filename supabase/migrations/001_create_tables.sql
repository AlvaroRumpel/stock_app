-- =============================================================
-- Stock App - Migração 001: Criação das tabelas principais
-- Aplicar no Supabase Dashboard > SQL Editor
-- =============================================================

-- Tabela city (referência de municípios brasileiros)
CREATE TABLE IF NOT EXISTS city (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  city_name  text        NOT NULL,
  state_name text        NOT NULL,
  uf         text        NOT NULL,
  code       int4        NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Tabela customer (clientes)
CREATE TABLE IF NOT EXISTS customer (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text        NOT NULL,
  phone       text        NOT NULL,
  address     text,
  observation text,
  city_id     uuid        REFERENCES city(id),
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz,
  deleted_at  timestamptz
);

-- Tabela product (estoque: barris e chopeiras)
-- volume: '30' ou '50' (litros)
-- type:   'barrel' ou 'dispenser'
CREATE TABLE IF NOT EXISTS product (
  id                 uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz,
  deleted_at         timestamptz,
  batch_number       text,
  volume             text,
  available_quantity int4,
  expiration_date    timestamptz,
  cost_price         numeric,
  sale_price         numeric,
  identify_number    int4,
  observation        text,
  type               text        NOT NULL
);
