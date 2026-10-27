drop policy if exists "Therapists can view their bookings" on public.booking;
create policy "Therapists can view their bookings"
  on public.booking for select to authenticated
  using (auth.uid() = therapist_id);

drop policy if exists "Admins can view all bookings" on public.booking;
create policy "Admins can view all bookings"
  on public.booking for select to authenticated
  using (exists (
    select 1 from public."user" profile
    where profile.id = auth.uid() and profile.role = 'admin'
  ));

drop policy if exists "Therapists can update their bookings" on public.booking;
create policy "Therapists can update their bookings"
  on public.booking for update to authenticated
  using (auth.uid() = therapist_id)
  with check (auth.uid() = therapist_id);

drop policy if exists "Admins can update all bookings" on public.booking;
create policy "Admins can update all bookings"
  on public.booking for update to authenticated
  using (exists (
    select 1 from public."user" profile
    where profile.id = auth.uid() and profile.role = 'admin'
  ))
  with check (exists (
    select 1 from public."user" profile
    where profile.id = auth.uid() and profile.role = 'admin'
  ));
