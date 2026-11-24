-- Availability is generated from the weekly rules and should be visible to guests.
drop policy if exists "Anyone can view booking rules" on public.rules;
create policy "Anyone can view booking rules"
  on public.rules for select to anon, authenticated using (true);
