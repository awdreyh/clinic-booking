create type public.user_role as enum ('user', 'doctor', 'admin');

create table public.user (
 id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text,
  phone text unique,
  role public.user_role not null default 'user',
  created_at timestamp with time zone default now()
);

-- Populate public."user" whenever a new auth.users row is created.
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

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();



create table public.room (
  id bigint generated always as identity primary key,
  name text not null,
  department text,
  status text check (status in ('active', 'paused')) default 'active',
  created_at timestamp with time zone default now()
);
create table public.timeslot (
  id bigint generated always as identity primary key,
  room_id bigint references public.room(id) on delete cascade,
  date date not null,
  start_time time not null,
  end_time time not null,
  capacity int default 1,
  used_count int default 0,
  created_at timestamp with time zone default now()
);
create table public.booking (
  id bigint generated always as identity primary key,
  user_id uuid references public.user(id) on delete cascade,
  room_id bigint references public.room(id) on delete cascade,
  timeslot_id bigint references public.timeslot(id) on delete cascade,
  status text check (status in ('booked', 'cancelled')) default 'booked',
  created_at timestamp with time zone default now()
);
create table public.doctor_schedule (
  id bigint generated always as identity primary key,
  doctor_id uuid references public.user(id) on delete cascade,
  room_id bigint references public.room(id) on delete cascade,
  date date not null,
  timeslot_id bigint references public.timeslot(id) on delete cascade,
  created_at timestamp with time zone default now()
);
