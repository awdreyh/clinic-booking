create table public.booking_service (
  id bigint generated always as identity primary key,
  booking_id bigint not null references public.booking(id) on delete cascade,
  service_id bigint not null references public.service(id) on delete restrict,
  duration integer,
  price numeric(10,2) not null check (price >= 0),
  created_at timestamptz not null default now(),
  check (duration is null or duration > 0),
  unique (booking_id, service_id)
);

create index booking_service_booking_id_idx on public.booking_service (booking_id);

-- Preserve the existing single-service booking records as line items.
insert into public.booking_service (booking_id, service_id, duration, price)
select b.id, b.service_id,
       case when b.duration is null then null
            else nullif(regexp_replace(b.duration::text, '[^0-9]', '', 'g'), '')::integer end,
       coalesce(b.price, 0)
from public.booking b
where b.service_id is not null
on conflict (booking_id, service_id) do nothing;

alter table public.booking_service enable row level security;

create policy "Customers can view their booking services"
  on public.booking_service for select to authenticated
  using (exists (select 1 from public.booking b where b.id = booking_id and b.customer_id = auth.uid()));

create policy "Therapists can view assigned booking services"
  on public.booking_service for select to authenticated
  using (exists (select 1 from public.booking b where b.id = booking_id and b.therapist_id = auth.uid()));

grant select on public.booking_service to authenticated;
