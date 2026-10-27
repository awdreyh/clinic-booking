create table if not exists public.rules (
  id bigint generated always as identity primary key,
  day_of_week smallint not null unique check (day_of_week between 0 and 6),
  start_time time not null default '09:00',
  end_time time not null default '21:00',
  slot_duration integer not null default 30 check (slot_duration > 0),
  created_at timestamp with time zone default now(),
  check (start_time < end_time)
);

insert into public.rules (day_of_week, start_time, end_time, slot_duration)
select day_of_week, '09:00', '21:00', 30
from generate_series(0, 6) as day_of_week
on conflict (day_of_week) do nothing;

alter table public.rules enable row level security;
drop policy if exists "Anyone can view booking rules" on public.rules;
create policy "Anyone can view booking rules"
  on public.rules for select to authenticated using (true);

alter table public.booking add column if not exists booking_date date;
alter table public.booking add column if not exists start_time time;
alter table public.booking add column if not exists end_time time;

do $$
begin
  if to_regclass('public.timeslot') is not null then
    execute $migration$
      update public.booking as booking
      set booking_date = timeslot.date,
          start_time = timeslot.start_time,
          end_time = timeslot.end_time
      from public.timeslot as timeslot
      where booking.timeslot_id = timeslot.id
        and (booking.booking_date is null or booking.start_time is null or booking.end_time is null)
    $migration$;
  end if;
end;
$$;

alter table public.booking alter column booking_date set not null;
alter table public.booking alter column start_time set not null;
alter table public.booking alter column end_time set not null;
alter table public.booking drop column if exists timeslot_id;
drop table if exists public.timeslot;

create unique index if not exists booking_active_therapist_slot_unique
  on public.booking (therapist_id, booking_date, start_time)
  where status in ('booked', 'pending');
