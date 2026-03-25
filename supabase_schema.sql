-- Controlled Drugs Management System - Supabase schema
-- Run this in Supabase SQL Editor

create extension if not exists pgcrypto;

create table if not exists public.meta (
  id text primary key,
  "createdAt" timestamptz,
  "updatedAt" timestamptz
);

create table if not exists public.users (
  id text primary key,
  "displayName" text,
  role text,
  "pharmacyScope" jsonb default '[]'::jsonb,
  "canAudit" boolean default false,
  "passwordHash" text,
  "mustChangePassword" boolean default true,
  active boolean default true,
  "createdAt" timestamptz,
  "updatedAt" timestamptz
);

create table if not exists public.settings (
  id text primary key,
  "pharmacyType" text,
  month text,
  year integer,
  "updatedAt" timestamptz
);

create table if not exists public.pharmacists (
  id text primary key,
  name text,
  workplace text,
  pharmacies jsonb default '[]'::jsonb,
  "canAudit" boolean default false,
  active boolean default true,
  "createdAt" timestamptz,
  "updatedAt" timestamptz
);

create table if not exists public.drugs (
  id text primary key,
  "scientificName" text,
  "tradeName" text,
  category text,
  strength text,
  "dosageForm" text,
  "unitsPerBox" integer default 30,
  "reorderLevelUnits" integer default 30,
  active boolean default true,
  "createdAt" timestamptz,
  "updatedAt" timestamptz
);

create table if not exists public.inventory (
  id text primary key,
  "drugId" text,
  pharmacy text,
  boxes integer default 0,
  units integer default 0,
  "totalUnits" integer default 0,
  "updatedAt" timestamptz
);

create table if not exists public.prescriptions (
  id text primary key,
  "dateTime" timestamptz,
  "patientName" text,
  "fileNumber" text,
  "drugId" text,
  "doctorName" text,
  "pharmacistName" text,
  pharmacy text,
  "qtyBoxes" integer default 0,
  "qtyUnits" integer default 0,
  status text,
  "auditBy" text,
  "auditNote" text,
  "updatedBy" text,
  "createdAt" timestamptz,
  "updatedAt" timestamptz
);

create table if not exists public.transactions (
  id text primary key,
  type text,
  "drugId" text,
  "tradeName" text,
  pharmacy text,
  "qtyBoxes" integer default 0,
  "qtyUnits" integer default 0,
  "performedBy" text,
  note text,
  "dateTime" timestamptz
);

-- Basic indexes
create index if not exists idx_inventory_drug_pharmacy on public.inventory ("drugId", pharmacy);
create index if not exists idx_prescriptions_drug on public.prescriptions ("drugId");
create index if not exists idx_prescriptions_pharmacy on public.prescriptions (pharmacy);
create index if not exists idx_transactions_pharmacy on public.transactions (pharmacy);

-- Enable Row Level Security
alter table public.meta enable row level security;
alter table public.users enable row level security;
alter table public.settings enable row level security;
alter table public.pharmacists enable row level security;
alter table public.drugs enable row level security;
alter table public.inventory enable row level security;
alter table public.prescriptions enable row level security;
alter table public.transactions enable row level security;

-- WARNING:
-- These policies allow anon browser access because this app currently uses its own in-app login,
-- not Supabase Auth. Use only if you understand the security tradeoff.
drop policy if exists "anon full access meta" on public.meta;
create policy "anon full access meta" on public.meta for all to anon using (true) with check (true);

drop policy if exists "anon full access users" on public.users;
create policy "anon full access users" on public.users for all to anon using (true) with check (true);

drop policy if exists "anon full access settings" on public.settings;
create policy "anon full access settings" on public.settings for all to anon using (true) with check (true);

drop policy if exists "anon full access pharmacists" on public.pharmacists;
create policy "anon full access pharmacists" on public.pharmacists for all to anon using (true) with check (true);

drop policy if exists "anon full access drugs" on public.drugs;
create policy "anon full access drugs" on public.drugs for all to anon using (true) with check (true);

drop policy if exists "anon full access inventory" on public.inventory;
create policy "anon full access inventory" on public.inventory for all to anon using (true) with check (true);

drop policy if exists "anon full access prescriptions" on public.prescriptions;
create policy "anon full access prescriptions" on public.prescriptions for all to anon using (true) with check (true);

drop policy if exists "anon full access transactions" on public.transactions;
create policy "anon full access transactions" on public.transactions for all to anon using (true) with check (true);

-- Realtime publication
alter publication supabase_realtime add table public.drugs;
alter publication supabase_realtime add table public.inventory;
alter publication supabase_realtime add table public.prescriptions;
alter publication supabase_realtime add table public.transactions;
alter publication supabase_realtime add table public.pharmacists;
alter publication supabase_realtime add table public.settings;
alter publication supabase_realtime add table public.users;
alter publication supabase_realtime add table public.meta;
