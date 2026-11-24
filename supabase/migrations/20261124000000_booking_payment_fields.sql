alter table public.booking
  add column if not exists payment_intent_id text unique,
  add column if not exists payment_status text not null default 'unpaid'
    check (payment_status in ('unpaid', 'requires_payment_method', 'succeeded', 'failed', 'cancelled'));
