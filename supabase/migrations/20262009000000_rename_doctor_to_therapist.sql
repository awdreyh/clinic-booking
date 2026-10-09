-- Rename the clinician role and schedule from doctor to therapist.
alter type public.user_role rename value 'doctor' to 'therapist';
alter table public.doctor_schedule rename to therapist_schedule;
alter table public.therapist_schedule rename column doctor_id to therapist_id;

-- Bookings now know their therapist and, for recurring bookings, their series.
alter table public.booking
  add column therapist_id uuid references public."user"(id) on delete set null,
  add column recurrence_type text not null default 'single',
  add column recurrence_group_id uuid;

alter table public.booking
  drop constraint if exists booking_recurrence_type_check;
alter table public.booking
  add constraint booking_recurrence_type_check
  check (recurrence_type in ('single', 'weekly', 'fortnightly', 'monthly'));

alter table public.timeslot
  drop constraint if exists timeslot_used_count_within_capacity;
alter table public.timeslot
  add constraint timeslot_used_count_within_capacity
  check (used_count >= 0 and used_count <= capacity);

-- Keep slot availability in sync for bookings created from any client. The
-- capacity predicate prevents two simultaneous inserts from overbooking a slot.
create or replace function public.sync_timeslot_used_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if TG_OP = 'DELETE' then
    if old.status = 'booked' then
      update public.timeslot
      set used_count = greatest(used_count - 1, 0)
      where id = old.timeslot_id;
    end if;
    return old;
  end if;

  if TG_OP = 'UPDATE'
     and old.status = 'booked'
     and (new.status <> 'booked' or new.timeslot_id <> old.timeslot_id) then
    update public.timeslot
    set used_count = greatest(used_count - 1, 0)
    where id = old.timeslot_id;
  end if;

  if (TG_OP = 'INSERT' and new.status = 'booked')
     or (TG_OP = 'UPDATE'
         and new.status = 'booked'
         and (old.status <> 'booked' or new.timeslot_id <> old.timeslot_id)) then
    update public.timeslot
    set used_count = used_count + 1
    where id = new.timeslot_id
      and used_count < capacity;

    if not found then
      raise exception 'The selected timeslot is fully booked';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists sync_booking_timeslot_used_count on public.booking;
create trigger sync_booking_timeslot_used_count
  after insert or update of status, timeslot_id or delete
  on public.booking
  for each row execute function public.sync_timeslot_used_count();

drop policy if exists "Doctors see their room bookings" on public.booking;
create policy "Therapists see their room bookings"
on public.booking
for select
using (
  exists (
    select 1
    from public.therapist_schedule schedule
    where schedule.therapist_id = auth.uid()
      and schedule.room_id = booking.room_id
  )
);
