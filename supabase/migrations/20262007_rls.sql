alter table public.booking enable row level security;

create policy "Users can view their own bookings"
on public.booking
for select
using (auth.uid() = customer_id);
create policy "Users can create their own bookings"
on public.booking
for insert
with check (auth.uid() = customer_id);





