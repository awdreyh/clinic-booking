-- Rename demo clinician accounts created before the doctor-to-therapist rename.
update auth.users
set
  email = replace(email, 'doctor', 'therapist'),
  raw_user_meta_data = jsonb_set(
    raw_user_meta_data,
    '{name}',
    to_jsonb(replace(raw_user_meta_data ->> 'name', 'Doctor', 'Therapist'))
  ),
  updated_at = now()
where email in ('doctor1@example.com', 'doctor2@example.com', 'doctor3@example.com');

update public."user"
set
  email = replace(email, 'doctor', 'therapist'),
  name = replace(name, 'Doctor', 'Therapist')
where email in ('doctor1@example.com', 'doctor2@example.com', 'doctor3@example.com');
