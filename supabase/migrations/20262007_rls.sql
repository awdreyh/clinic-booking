alter table public.booking enable row level security;

create policy "Users can view their own bookings"
on public.booking
for select
using (auth.uid() = user_id);
create policy "Users can create their own bookings"
on public.booking
for insert
with check (auth.uid() = user_id);

alter table public.room enable row level security;

create policy "Users can view all rooms"
on public.room
for select
using (true);

alter table public.timeslot enable row level security;

create policy "Users can view all timeslots"
on public.timeslot
for select
using (true);




create policy "Doctors see their room bookings"
on public.booking
for select
using (
  exists (
    select 1 from public.doctor_schedule ds
    where ds.doctor_id = auth.uid()
      and ds.room_id = booking.room_id
  )
);

alter table public.booking replica identity full;
