-- Supabase schema for Inside Out Turf production setup.
create extension if not exists pgcrypto;
create table if not exists public.pitches (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  active boolean not null default true
);
insert into public.pitches(name) values ('Main Pitch'),('Full Ground') on conflict do nothing;
create table if not exists public.pricing_rules (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  sport text not null check (sport in ('Football','Box Cricket')),
  day_type text not null check (day_type in ('weekday','weekend','all')),
  start_time time not null,
  end_time time not null,
  price_per_slot integer not null check (price_per_slot >= 0),
  active boolean not null default true
);
create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  booking_code text not null unique,
  customer_name text not null,
  phone text not null,
  email text,
  sport text not null check (sport in ('Football','Box Cricket')),
  pitch text not null,
  booking_date date not null,
  slot_times text[] not null,
  total_amount integer not null check (total_amount >= 0),
  paid_amount integer not null default 0 check (paid_amount >= 0),
  payment_status text not null default 'pending',
  payment_reference text,
  status text not null default 'pending' check (status in ('pending','confirmed','cancelled','completed')),
  hold_expires_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists bookings_date_status_idx on public.bookings(booking_date,status);
create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id),
  rating integer not null check (rating between 1 and 5),
  review_text text,
  created_at timestamptz not null default now()
);
-- Slot-level uniqueness is enforced by expanding selected slot arrays into a separate reservation table.
create table if not exists public.booking_slots (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  pitch text not null,
  booking_date date not null,
  slot_time time not null,
  unique (pitch, booking_date, slot_time)
);
-- Use this RPC from a trusted server/Edge Function. A transaction plus the unique constraint
-- prevents concurrent users from confirming the same pitch/date/time.
create or replace function public.create_booking_with_slots(
  p_booking_code text, p_customer_name text, p_phone text, p_email text,
  p_sport text, p_pitch text, p_date date, p_slots text[],
  p_total integer, p_paid integer
) returns uuid language plpgsql security definer set search_path = public as $$
declare new_id uuid;
begin
  if coalesce(array_length(p_slots,1),0) = 0 then raise exception 'Select at least one slot'; end if;
  insert into bookings(booking_code,customer_name,phone,email,sport,pitch,booking_date,slot_times,total_amount,paid_amount,status)
  values(p_booking_code,p_customer_name,p_phone,p_email,p_sport,p_pitch,p_date,p_slots,p_total,p_paid,'confirmed') returning id into new_id;
  insert into booking_slots(booking_id,pitch,booking_date,slot_time)
  select new_id,p_pitch,p_date,s::time from unnest(p_slots) s;
  return new_id;
exception when unique_violation then
  raise exception 'One or more selected slots have just been booked. Please refresh availability.';
end; $$;
-- Do not expose customer data to anon users. Keep RLS enabled and use a trusted backend for writes.
alter table public.bookings enable row level security;
alter table public.booking_slots enable row level security;
alter table public.pricing_rules enable row level security;
alter table public.pitches enable row level security;
alter table public.reviews enable row level security;
