-- Email/password signup does not require a phone number. The auth trigger
-- provides a default display name and assigns new accounts the user role.
alter table public."user"
  alter column phone drop not null,
  alter column role set default 'user';

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public."user" (id, name, email, phone, role)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data->>'name', ''), nullif(split_part(coalesce(new.email, ''), '@', 1), ''), new.id::text),
    new.email,
    nullif(new.raw_user_meta_data->>'phone', ''),
    'user'::public.user_role
  )
  on conflict (id) do nothing;
  return new;
end;
$$;
