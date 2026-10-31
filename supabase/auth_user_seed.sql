-- Local Supabase therapist accounts for development and demos.
-- Passwords are stored using Supabase's pgcrypto-compatible bcrypt hash.
insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  phone,
  phone_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
)
values
  (
    '00000000-0000-0000-0000-000000000000',
    '4fc7d318-71e9-4f03-b12c-9e276aa75101', 'authenticated', 'authenticated',
    'ray@example.com', extensions.crypt('123456', extensions.gen_salt('bf')),
    now(), '021-123456', now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"name":"Ray","phone":"021-123456"}'::jsonb, now(), now()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '4fc7d318-71e9-4f03-b12c-9e276aa75102', 'authenticated', 'authenticated',
    'amy@example.com', extensions.crypt('123456', extensions.gen_salt('bf')),
    now(), '021-1234561', now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"name":"Amy","phone":"021-1234561"}'::jsonb, now(), now()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '4fc7d318-71e9-4f03-b12c-9e276aa75103', 'authenticated', 'authenticated',
    'tina@example.com', extensions.crypt('123456', extensions.gen_salt('bf')),
    now(), '021-1234562', now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"name":"Tina","phone":"021-1234562"}'::jsonb, now(), now()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '4fc7d318-71e9-4f03-b12c-9e276aa75104', 'authenticated', 'authenticated',
    'min@example.com', extensions.crypt('123456', extensions.gen_salt('bf')),
    now(), '021-1234563', now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"name":"Min","phone":"021-1234563"}'::jsonb, now(), now()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '4fc7d318-71e9-4f03-b12c-9e276aa75105', 'authenticated', 'authenticated',
    'audrey@example', extensions.crypt('123456', extensions.gen_salt('bf')),
    now(), '021-111222', now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"name":"Audrey","phone":"021-111222"}'::jsonb, now(), now()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '4fc7d318-71e9-4f03-b12c-9e276aa75106', 'authenticated', 'authenticated',
    'audrey.hong@gmail.com', extensions.crypt('111222333', extensions.gen_salt('bf')),
    now(), '021298764', now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"name":"Audrey Hong","phone":"021298764"}'::jsonb, now(), now()
  )
on conflict (id) do update set
  instance_id = excluded.instance_id,
  aud = excluded.aud,
  role = excluded.role,
  email = excluded.email,
  encrypted_password = excluded.encrypted_password,
  email_confirmed_at = excluded.email_confirmed_at,
  phone = excluded.phone,
  phone_confirmed_at = excluded.phone_confirmed_at,
  raw_app_meta_data = excluded.raw_app_meta_data,
  raw_user_meta_data = excluded.raw_user_meta_data,
  updated_at = excluded.updated_at;

-- GoTrue scans these as strings; normalize NULLs left by direct SQL inserts.
update auth.users
set confirmation_token = coalesce(confirmation_token, ''),
    recovery_token = coalesce(recovery_token, ''),
    email_change_token_new = coalesce(email_change_token_new, ''),
    email_change = coalesce(email_change, ''),
    phone_change = coalesce(phone_change, ''),
    phone_change_token = coalesce(phone_change_token, ''),
    email_change_token_current = coalesce(email_change_token_current, ''),
    reauthentication_token = coalesce(reauthentication_token, '')
where id in (
  '4fc7d318-71e9-4f03-b12c-9e276aa75101',
  '4fc7d318-71e9-4f03-b12c-9e276aa75102',
  '4fc7d318-71e9-4f03-b12c-9e276aa75103',
  '4fc7d318-71e9-4f03-b12c-9e276aa75104',
  '4fc7d318-71e9-4f03-b12c-9e276aa75105',
  '4fc7d318-71e9-4f03-b12c-9e276aa75106'
);

-- Create the email identities required by Supabase Auth password sign-in.
insert into auth.identities (
  id,
  provider_id,
  user_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
)
values
  (
    '5fc7d318-71e9-4f03-b12c-9e276aa75101',
    '4fc7d318-71e9-4f03-b12c-9e276aa75101',
    '4fc7d318-71e9-4f03-b12c-9e276aa75101',
    '{"sub":"4fc7d318-71e9-4f03-b12c-9e276aa75101","email":"ray@example.com","email_verified":true,"phone_verified":true}'::jsonb,
    'email', now(), now(), now()
  ),
  (
    '5fc7d318-71e9-4f03-b12c-9e276aa75102',
    '4fc7d318-71e9-4f03-b12c-9e276aa75102',
    '4fc7d318-71e9-4f03-b12c-9e276aa75102',
    '{"sub":"4fc7d318-71e9-4f03-b12c-9e276aa75102","email":"amy@example.com","email_verified":true,"phone_verified":true}'::jsonb,
    'email', now(), now(), now()
  ),
  (
    '5fc7d318-71e9-4f03-b12c-9e276aa75103',
    '4fc7d318-71e9-4f03-b12c-9e276aa75103',
    '4fc7d318-71e9-4f03-b12c-9e276aa75103',
    '{"sub":"4fc7d318-71e9-4f03-b12c-9e276aa75103","email":"tina@example.com","email_verified":true,"phone_verified":true}'::jsonb,
    'email', now(), now(), now()
  ),
  (
    '5fc7d318-71e9-4f03-b12c-9e276aa75104',
    '4fc7d318-71e9-4f03-b12c-9e276aa75104',
    '4fc7d318-71e9-4f03-b12c-9e276aa75104',
    '{"sub":"4fc7d318-71e9-4f03-b12c-9e276aa75104","email":"min@example.com","email_verified":true,"phone_verified":true}'::jsonb,
    'email', now(), now(), now()
  ),
  (
    '5fc7d318-71e9-4f03-b12c-9e276aa75105',
    '4fc7d318-71e9-4f03-b12c-9e276aa75105',
    '4fc7d318-71e9-4f03-b12c-9e276aa75105',
    '{"sub":"4fc7d318-71e9-4f03-b12c-9e276aa75105","email":"audrey@example","email_verified":true,"phone_verified":true}'::jsonb,
    'email', now(), now(), now()
  ),
  (
    '5fc7d318-71e9-4f03-b12c-9e276aa75106',
    '4fc7d318-71e9-4f03-b12c-9e276aa75106',
    '4fc7d318-71e9-4f03-b12c-9e276aa75106',
    '{"sub":"4fc7d318-71e9-4f03-b12c-9e276aa75106","email":"audrey.hong@gmail.com","email_verified":true,"phone_verified":true}'::jsonb,
    'email', now(), now(), now()
  )
on conflict (id) do update set
  provider_id = excluded.provider_id,
  user_id = excluded.user_id,
  identity_data = excluded.identity_data,
  provider = excluded.provider,
  updated_at = excluded.updated_at;

-- The auth trigger creates customer profiles; promote these seeded profiles.
insert into public."user" (id, name, email, phone, role, is_active)
values
  ('4fc7d318-71e9-4f03-b12c-9e276aa75101', 'Ray', 'ray@example.com', '021-123456', 'therapist', true),
  ('4fc7d318-71e9-4f03-b12c-9e276aa75102', 'Amy', 'amy@example.com', '021-1234561', 'therapist', true),
  ('4fc7d318-71e9-4f03-b12c-9e276aa75103', 'Tina', 'tina@example.com', '021-1234562', 'therapist', true),
  ('4fc7d318-71e9-4f03-b12c-9e276aa75104', 'Min', 'min@example.com', '021-1234563', 'therapist', true),
  ('4fc7d318-71e9-4f03-b12c-9e276aa75105', 'Audrey', 'audrey@example', '021-111222', 'customer', true),
  ('4fc7d318-71e9-4f03-b12c-9e276aa75106', 'Audrey Hong', 'audrey.hong@gmail.com', '021298764', 'admin', true)
on conflict (id) do update set
  name = excluded.name,
  email = excluded.email,
  phone = excluded.phone,
  role = excluded.role,
  is_active = excluded.is_active,
  updated_at = now();

-- Link every seeded therapist to every service already present in the catalog.
insert into public.service_therapist (therapist_id, service_id)
select therapist.id, service.id
from public."user" as therapist
cross join public.service as service
where therapist.role = 'therapist'
  and not exists (
    select 1
    from public.service_therapist as existing
    where existing.therapist_id = therapist.id
      and existing.service_id = service.id
  );
