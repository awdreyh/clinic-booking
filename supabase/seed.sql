-- Demo rooms
insert into public.room (name, department, status)
select seed.name, seed.department, 'active'
from (values
  ('Room 1', 'General Practice'),
  ('Room 2', 'Pediatrics'),
  ('Room 3', 'Cardiology')
) as seed(name, department)
where not exists (
  select 1
  from public.room existing
  where existing.name = seed.name
);

-- Demo therapist Auth identities. These accounts are confirmed but have no usable
-- password; assign credentials through Supabase Auth before enabling sign-in.
insert into auth.users (
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
)
select
  seed.id,
  'authenticated',
  'authenticated',
  seed.email,
  '',
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  jsonb_build_object('name', seed.name),
  now(),
  now()
from (values
  ('10000000-0000-4000-8000-000000000001'::uuid, 'therapist1@example.com', 'Therapist 1'),
  ('10000000-0000-4000-8000-000000000002'::uuid, 'therapist2@example.com', 'Therapist 2'),
  ('10000000-0000-4000-8000-000000000003'::uuid, 'therapist3@example.com', 'Therapist 3')
) as seed(id, email, name)
where not exists (
  select 1
  from auth.users existing
  where lower(existing.email) = lower(seed.email)
)
on conflict (id) do nothing;

-- Ensure each seeded Auth identity has a therapist profile, including when an
-- account with the demo email already existed before the seed ran.
insert into public."user" (id, name, email, role)
select auth_user.id, seed.name, auth_user.email, 'therapist'::public.user_role
from (values
  ('therapist1@example.com', 'Therapist 1'),
  ('therapist2@example.com', 'Therapist 2'),
  ('therapist3@example.com', 'Therapist 3')
) as seed(email, name)
join auth.users auth_user
  on lower(auth_user.email) = lower(seed.email)
on conflict (id) do update
set name = excluded.name,
    role = excluded.role;

-- Demo admin and regular-user Auth identities. Like the therapist identities,
-- these are confirmed Auth accounts with no usable password until one is set
-- through the Auth Admin API.
insert into auth.users (
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
)
select
  seed.id,
  'authenticated',
  'authenticated',
  seed.email,
  '',
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  jsonb_build_object('name', seed.name),
  now(),
  now()
from (values
  ('20000000-0000-4000-8000-000000000001'::uuid, 'admin@example.com', 'Admin'),
  ('30000000-0000-4000-8000-000000000001'::uuid, 'user1@example.com', 'User 1'),
  ('30000000-0000-4000-8000-000000000002'::uuid, 'user2@example.com', 'User 2'),
  ('30000000-0000-4000-8000-000000000003'::uuid, 'user3@example.com', 'User 3')
) as seed(id, email, name)
where not exists (
  select 1
  from auth.users existing
  where lower(existing.email) = lower(seed.email)
)
on conflict (id) do nothing;

-- Ensure the Auth identities have matching public profiles and roles.
insert into public."user" (id, name, email, role)
select auth_user.id, seed.name, auth_user.email, seed.profile_role::public.user_role
from (values
  ('admin@example.com', 'Admin', 'admin'),
  ('user1@example.com', 'User 1', 'user'),
  ('user2@example.com', 'User 2', 'user'),
  ('user3@example.com', 'User 3', 'user')
) as seed(email, name, profile_role)
join auth.users auth_user
  on lower(auth_user.email) = lower(seed.email)
on conflict (id) do update
set name = excluded.name,
    role = excluded.role;

-- Generate five weeks of demo timeslots for every active room.
insert into public.timeslot (room_id, date, start_time, end_time, capacity, used_count)
select room.id, availability.date::date, slot.start_time, slot.end_time, 1, 0
from public.room room
cross join generate_series(
  current_date,
  current_date + 35,
  interval '1 day'
) as availability(date)
cross join (values
  (time '09:00', time '09:30'),
  (time '10:00', time '10:30'),
  (time '11:00', time '11:30')
) as slot(start_time, end_time)
where room.status = 'active'
  and not exists (
    select 1
    from public.timeslot existing
    where existing.room_id = room.id
      and existing.date = availability.date::date
      and existing.start_time = slot.start_time
  );

-- Make every seeded therapist available in every active room. The booking form
-- uses these rows to enable calendar dates and list available times.
insert into public.therapist_schedule (therapist_id, room_id, date, timeslot_id)
select therapist.id, room.id, slot.date, slot.id
from public."user" therapist
join public.room room on room.status = 'active'
join public.timeslot slot
  on slot.room_id = room.id
  and slot.date between current_date and current_date + 35
where therapist.role = 'therapist'::public.user_role
  and not exists (
    select 1
    from public.therapist_schedule existing
    where existing.therapist_id = therapist.id
      and existing.timeslot_id = slot.id
  );

-- One booking for each regular user, with a matching therapist, room, and slot.
insert into public.booking (user_id, therapist_id, room_id, timeslot_id, status)
select patient.id, therapist.id, room.id, timeslot.id, 'booked'
from (values
  ('user1@example.com', 'therapist1@example.com', 'Room 1', time '09:00'),
  ('user2@example.com', 'therapist2@example.com', 'Room 2', time '10:00'),
  ('user3@example.com', 'therapist3@example.com', 'Room 3', time '11:00')
) as seed(user_email, therapist_email, room_name, start_time)
join auth.users auth_user on lower(auth_user.email) = lower(seed.user_email)
join public."user" patient on patient.id = auth_user.id
join public."user" therapist
  on lower(therapist.email) = lower(seed.therapist_email)
join public.room room on room.name = seed.room_name
join public.timeslot timeslot
  on timeslot.room_id = room.id
  and timeslot.date = current_date
  and timeslot.start_time = seed.start_time
where not exists (
  select 1
  from public.booking existing
  where existing.user_id = patient.id
    and existing.timeslot_id = timeslot.id
);

